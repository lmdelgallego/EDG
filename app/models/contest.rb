require 'file_size_validator'
class Contest < ActiveRecord::Base
  include PublicActivity::Common
  include ActionView::Helpers::DateHelper

  extend FriendlyId
  friendly_id :name

  attr_accessor :end_hour, :start_hour

  validates :name, :description, :additional_details, :start_date, :end_time, :reward, :judging_criteria, presence: true
  validates :status, presence: true, inclusion: { in: %w(pending active paused closed finished) }
  validates :private, inclusion: [true, false]

  validates :caption_image, presence: { if: Proc.new { |contest| contest.categories.pluck(:name).include?("caption") } }
  validates :cover_photo, :file_size => { :maximum => 4.megabytes.to_i }

  belongs_to :admin
  has_many :entries, dependent: :destroy
  has_many :category_contests
  has_many :categories, through: :category_contests
  has_many :watch_lists
  has_many :users, through: :watch_lists
  has_one :search_result, :as => :searchable
  accepts_nested_attributes_for :category_contests, :allow_destroy => true

  mount_uploader :cover_photo, ImageUploader
  mount_uploader :caption_image, ImageUploader
  mount_uploader :sponsor_photo, ImageUploader
  mount_uploader :banner_photo, ImageUploader
  mount_uploader :cover_m_photo, ImageUploader

  before_save :open_if_start_date_close_if_end_date
  after_create :autocreate_searchable
  after_update :update_searchable

  scope :by_type, -> (contest_type) { Category.find_by_name(contest_type).contests }
  scope :active, -> { where(status: "active") }
  scope :closed, -> { where(status: "closed") }
  scope :listable, -> { where(private: false, status: ["active", "closed"]) }
  scope :by_status, -> (contest_status){ where(private: false, status: contest_status) }
  scope :by_status_adm, -> (contest_status){ where(status: contest_status) }
  scope :by_premium, ->(contest_premium) { where(premium: contest_premium) }
  scope :free, -> { where(premium: false) }
  scope :similar_contests, -> (category){joins(:categories).where("categories.name = ?", category)}
  scope :not_include, -> (exclude) { where.not( id: exclude ) }

  def paused?
    status == "paused"
  end

  def pause!
    self.status = "paused"
    save
  end

  def resume!
    self.status = "active"
    save
  end

  def closed?
    status == "closed"
  end

  def close!
    self.status = "closed"
    save
  end

  def finish!
    self.status = "finished"
    save
  end

  def finished?
    status == "finished"
  end

  def pending!
    self.status = "pending"
    save
  end

  def pending?
    status == "pending"
  end

  def visits_count
    Ahoy::Event.where(name: "Viewed contest #{self.id}").uniq.count(:visit_id)
  end

  def self.total_visitors
    Ahoy::Event.joins(:visit).uniq.count("visits.visitor_id")
  end

  def visitors_count
    Ahoy::Event.where(name: "Viewed contest #{self.id}").joins(:visit).uniq.count("visits.visitor_id")
  end

  def has_winner?
    !self.entries.select { |entry| entry.winner }.empty?
  end

  def open_if_start_date_close_if_end_date
    today = Time.zone.now

     if self.status == "active" && self.end_time <= today
      puts "Change status to closed"
      self.status = "closed"
    end

    if self.status != 'paused' && self.start_date <= today && self.end_time > today
      puts "Change status to active"
      self.status = "active"
    end

    if self.start_date > today
      puts "Change status to pending"
      self.status = "pending"
    end
  end

  def end_time_to_end_of_day
    self.end_time = self.end_time.end_of_day
  end

  def notify_users
    user_ids = self.entries.pluck(:user_id).uniq
    user_ids.each do |id|
      user = User.find(id)
      user.create_activity key: 'contest.closed', owner: self
    end
  end

  def new_entries_count_in_days(days_ago)
    self.entries.where("DATE(created_at) >= ?", Date.today-days_ago).count
  end

  def new_entries_in_days(days_ago)
    self.entries.where("DATE(created_at) >= ?", Date.today-days_ago)
  end

  def autocreate_searchable
    SearchResult.create(content: self.name, searchable: self)
  end

  def update_searchable
    self.search_result.update(content: self.name) if self.search_result.present?
  end

  class << self

    # Added optional arguments for easy of use whilst updating the new frontend
    def contest_filter(type, status, premium, page, order)
      order_p = order.present? ? "updated_at #{order}" : "updated_at DESC"
      if type.present? && premium.present?
        contests = Contest.by_type(type).by_status(status).by_premium(premium).order(order_p).paginate(page: page, per_page: 9)
      elsif type.present?
        contests = Contest.by_type(type).by_status(status).order(order_p).paginate(page: page, per_page: 9)
      elsif premium.present?
        contests = Contest.by_status(status).by_premium(premium).order(order_p).paginate(page: page, per_page: 9)
      else
        contests = Contest.by_status(status).order(order_p).paginate(page: page, per_page: 9)
      end

    end
    def contest_filter_admin(type,status,premium,page)
      if type != "" && premium != ""
        puts Category.find_by_name(type)
        contests = Contest.by_type(type).by_status_adm(status).by_premium(premium).order('updated_at DESC').paginate(page: page, per_page: 10)
      elsif type != ""
        contests = Contest.by_type(type).by_status_adm(status).order('updated_at DESC').paginate(page: page, per_page: 10)
      elsif premium != ""
        contests = Contest.by_status_adm(status).by_premium(premium).order('updated_at DESC').paginate(page: page, per_page: 10)
      else
        contests = Contest.by_status_adm(status).order('updated_at DESC').paginate(page: page, per_page: 10)
      end

    end

    def notify_to_admin
      today = Time.zone.now
      self.where(status: "active").each do |contest|
        diff = contest.end_time - today
        NotificationsMailer.delay.contest_will_close_soon(contest) if diff.between?(13400,15400)  || diff.between?(85400,87400)
      end
    end
    handle_asynchronously :notify_to_admin

    def open_contests
      puts "opening contests"
      today = Time.zone.now
      self.where(status: "pending").each do |contest|
        contest.update(status: "active") if contest.start_date <= today
      end
    end
    handle_asynchronously :open_contests

    def close_contests
      puts "closing contests"
      today = Time.zone.now
      where(status: ["active", "paused"]).each do |contest|
        if contest.end_time <= today
          contest.update(status: "closed")
          NotificationsMailer.delay.contest_closed(contest)
          contest.notify_users
        end
      end
    end
    handle_asynchronously :close_contests
  end

end
