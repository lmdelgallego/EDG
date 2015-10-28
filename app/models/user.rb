class User < ActiveRecord::Base
  
  include PublicActivity::Model
  
  extend FriendlyId
  friendly_id :username
  attr_accessor :stripe_token, :t_price, :mode
  
  before_create :create_membership
  after_create :add_user_id_to_membership
  after_create :autocreate_searchable
  after_commit :update_searchable
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter, :linkedin, :google] 

  validates :facebook_uid, :twitter_uid, :google_uid, :linkedin_uid, :username, uniqueness: true, allow_blank: true
  validates :description, length: { maximum: 500 }
  validate :zipcode_validator
  has_many :alma_mater_per_users, dependent: :destroy
  has_many :studies, dependent: :destroy
  has_many :donations, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :grants, dependent: :destroy
  has_many :social_urls, dependent: :destroy
  has_many :upvotes, dependent: :destroy
  has_many :watch_lists
  has_many :contests, through: :watch_lists
  has_one  :membership, dependent: :destroy
  has_one :search_result, :as => :searchable

  belongs_to :degree
  belongs_to :state
  belongs_to :major, 
             :class_name=>"Major",
             :foreign_key=>"major_course_id"

  belongs_to :minor, 
             :class_name=>"Minor",
             :foreign_key=>"minor_course_id"

  
  mount_uploader :profile_image, ImageUploader
  
  accepts_nested_attributes_for :alma_mater_per_users
  accepts_nested_attributes_for :studies, allow_destroy: true, reject_if: proc { |attributes| attributes['alma_mater_id']== "" || attributes['alma_mater_id']== nil}
  
  scope :name_is_like, -> (name) { where("full_name like ?", "%#{name}%") }
  scope :premium, -> { where(premium: true) }
  scope :free, -> { where(premium: false) }
  scope :daily, ->{ where(email_frequency: 1)}
  scope :each_3_days, ->{ where(email_frequency: 3)}
  scope :weekly, ->{ where(email_frequency: 7)}
  
  def zipcode_validator
    if self.zipcode.present?
    errors.add(:user, "wrong zipcode.") unless self.zipcode.length == 5 && !(self.zipcode =~ /\A\d+\Z/).nil?
  end
  end
  def self.from_omniauth(auth, donor_value)
    provider = auth.provider
    where("#{provider}_uid = ?", auth.uid).first_or_create do |user|
      user["#{provider}_uid"] = auth.uid
      user.username = auth.info.nickname
      user.email = auth.info.email if auth.info.email.present? && user.email.blank?
      user.full_name = auth.info.name if auth.info.name.present? && user.full_name.blank?
      #if provider == "facebook" || provider == "twitter"
       user.remote_profile_image_url = provider != "linkedin" ? auth.info.image : auth[:extra][:raw_info][:pictureUrls][:values].first
    # end
      #user.donor = donor_value
      url = provider != "linkedin" ? auth.info.urls["#{provider.capitalize}"] : auth.info.urls["public_profile"]
      user.social_urls.new(provider: provider, profile_url: url)
    end
  end

  def mark_as_premium
    self.update_attribute(:premium, true)
  end
  
  def password_required?
    super && ([facebook_uid, twitter_uid, google_uid, linkedin_uid].all? &:blank?)
  end
  
  def confirmation_required?
    if [facebook_uid, twitter_uid, google_uid, linkedin_uid].all? &:blank?
      !confirmed?
    else
      skip_confirmation_notification!
      self.confirmed_at = Time.now
    end
  end
  
  # Not require email when coming from twitter
  def email_required?
    super && twitter_uid.blank? || (!twitter_uid.blank? && persisted?)
  end
  
  # Get total amount of donations made
  def total_donations
    donations.successful.sum(:amount)
  end

  # Get total debt for user
  def total_debt
    self.amount
  end
  
  def connect_omniauth_account(auth)
    provider = auth.provider
    self["#{provider}_uid"] = auth.uid

    if self.valid?
      url = provider != "linkedin" ? auth.info.urls["#{provider.capitalize}"] : auth.info.urls["public_profile"]
      self.social_urls.new(provider: provider, profile_url: url)
    end
  end

  def has_social?
    !social_urls.empty?
  end

  def social_profile_for_provider(provider)
    # self.social_urls.where(provider: provider)
    SocialUrl.find_by(user_id: self.id, provider: provider)
  end
  
  def unread_notifications
    PublicActivity::Activity.where(trackable_type: "User", trackable_id: self.id, read: false).order('created_at DESC')
  end
  
  def mark_notifications_as_read
    PublicActivity::Activity.where(trackable_type: "User", trackable_id: self.id, read: false).order('created_at DESC').update_all(read: true)
  end

  def should_generate_new_friendly_id?
    slug.blank? || full_name_changed?
  end
  
  def create_membership
    if stripe_token.present?
      @plan = Plan.find(t_price.to_i)

      if mode == "m" 
        cent_amount = @plan.price.to_i * 100 
        date = Time.zone.now + 1.month
      elsif mode == "a"
        cent_amount = @plan.anual_price.to_i * 100
        date = Time.zone.now + 1.year
      end
      
      customer = Stripe::Customer.create(
        :card => stripe_token,
        :email => email,
        :description => "Subscription payment  - #{cent_amount} dollars."
      )
      Stripe::Charge.create(
        :amount => cent_amount, # in cents
        :currency => "usd",
        :customer => customer.id
      )

      subscription = Membership.create(user_email: email, stripe_customer_id: customer.id, status: true, plan_id: @plan.id, expiration_date: date) 
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "There was an error while charging your credit card. #{e.message}"
    false
  end

  
  def add_user_id_to_membership
    if stripe_token.present?
      subscription = Membership.find_by_user_email(self.email) 
      if subscription
        subscription.update_attribute(:user_id, id) 
        self.premium = true
        self.save
      end
    else
      subscription = Membership.create(user_id: self.id, status: true, user_email: self.email, plan_id: 1)
    end
  end

  def entries_email(days_ago)
    entries = self.entries.where("DATE(created_at) >= ?", Date.today-days_ago)
    contests = self.contests
    NotificationsMailer.user_new_entries(entries, days_ago, self).deliver if entries.present? || contests.present?
  end

  def autocreate_searchable
    SearchResult.create(content: "#{username} #{full_name} #{email}", searchable: self)
  end

  def update_searchable
    self.search_result.update(content: "#{username} #{full_name} #{email}") if self.search_result.present?
  end

  class << self
    def emails_daily
      self.daily.each{|user| user.entries_email(1)}
    end
    handle_asynchronously :emails_daily

    def emails_3_days
      self.each_3_days.each{|user| user.entries_email(3)}
    end
    handle_asynchronously :emails_3_days

    def emails_weekly
      self.weekly.each{|user| user.entries_email(7)}
    end
    handle_asynchronously :emails_weekly
  end

end
