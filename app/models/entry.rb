class Entry < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  attr_accessor :attachment

  YT_LINK_FORMAT = /\A.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i

  validates :name, :description, :contest_id, :user_id, presence: true
  validates :description, length: { maximum: 500 }
  validate :inside_contest_time_frame, :on => :create
  validate :inside_contest_max, :on => :create
  validate :validate_number_of_entries, :on => :create
  validates :body, presence: true, if: :is_text_contest?, :on => :create
  validates :video_url, format: YT_LINK_FORMAT, if: :is_video_contest?
  

  has_many :entry_attachments 
  has_many :upvotes, dependent: :destroy
  has_one :grant
  has_one :search_result, :as => :searchable
  has_many :comments, dependent: :destroy
  belongs_to :contest, counter_cache: true
  belongs_to :user, counter_cache: true
  accepts_nested_attributes_for :entry_attachments, :allow_destroy => true, :update_only => true
  
  scope :most_recent, -> { order('created_at DESC') }
  scope :most_upvotes, -> { order('upvotes_count DESC')}
  scope :winner_first, -> { order("winner DESC") }
  scope :by_category, -> (category) {  }

  after_create :autocreate_searchable
  after_commit :update_searchable

  def video_url_format
    uid = self.video_url.match(YT_LINK_FORMAT)
    uid[2]
  end

  def is_text_contest?
    self.contest.categories.pluck(:name).include?("text") ? true : false
  end

  def is_video_contest?
    self.contest.categories.pluck(:name).include?("video") ? true : false
  end
  def is_audio_contest?
    self.contest.categories.pluck(:name).include?("audio") ? true : false
  end
  def is_image_contest?
    self.contest.categories.pluck(:name).include?("image") ? true : false
  end

  def validate_number_of_entries
    errors.add(:user, "has reached maximum entries number.") if self.user.entries.count >= self.user.membership.plan.number_of_entries
  end

  def mark_as_winner!
    grant = self.create_grant(user_id: self.user_id, contest_id: self.contest_id)
    if grant
      self.winner= true
      save!
      self.contest.finish!
    else
      return false
    end
  end

  def undo_winner!
    self.grant.destroy!
    self.winner = false
    self.contest.close!
    save!
  end

  def is_winner?
    self.winner
  end

  def inside_contest_time_frame
    puts self.contest.status
     errors.add(:contest, "is not accepting entries at this moment") unless self.contest.status == "active"
  end
  
  def inside_contest_max
    errors.add(:user, "has reached maximum entries number") if self.user.entries.where(contest: self.contest).count == self.contest.max_entries_per_user
  end

  def update_nested_attributes(data)
    puts data.inspect
  end

  def autocreate_searchable
    SearchResult.create(content: self.name, searchable: self)
  end

  def update_searchable
    self.search_result.update(content: self.name) if self.search_result.present?
  end
end
