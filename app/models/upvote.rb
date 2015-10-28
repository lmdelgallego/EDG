class Upvote < ActiveRecord::Base
  validate :inside_contest_time_frame

  validates :user_id, uniqueness: { scope: :entry_id }

  belongs_to :entry, counter_cache: true
  belongs_to :user

  def inside_contest_time_frame
    errors.add(:entry, "is no longer accepting votes") if self.entry.contest.start_date > Time.zone.now || self.entry.contest.end_time < Time.zone.now
  end
end
