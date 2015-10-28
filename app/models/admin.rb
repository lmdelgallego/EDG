class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :invitable
  
  validates :name, presence: true
  
  has_many :contests
  
  mount_uploader :profile_image, ImageUploader
  
  scope :all_except, -> (user) { where.not(id: user) }
  scope :daily, ->{ where(email_frequency: 1)}
  scope :each_3_days, ->{ where(email_frequency: 3)}
  scope :weekly, ->{ where(email_frequency: 7)}

  def contest_email(days_ago)
  	contests = self.contests.select{|contest| contest.new_entries_count_in_days(days_ago) > 0}
  	NotificationsMailer.delay.new_entries_to_admin(contests, self, days_ago) if contests.present?
    
  end

  class << self
    def emails_daily
      self.daily.each{|admin| admin.contest_email(1)}
    end
    handle_asynchronously :emails_daily

    def emails_3_days
      self.each_3_days.each{|admin| admin.contest_email(3)}
    end
    handle_asynchronously :emails_3_days

    def emails_weekly
      self.weekly.each{|admin| admin.contest_email(7)}
    end
    handle_asynchronously :emails_weekly
  end


end
