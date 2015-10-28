class Comment < ActiveRecord::Base
  validates :message, :user, :entry, presence: true

  belongs_to :user
  belongs_to :entry
  
  scope :recent, -> { order('created_at DESC') }
end
