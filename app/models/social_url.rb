class SocialUrl < ActiveRecord::Base
  validates :provider, :profile_url, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: "already exists for this provider" }
  belongs_to :user
end
