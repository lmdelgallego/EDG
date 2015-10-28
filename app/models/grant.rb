class Grant < ActiveRecord::Base
  validates :user_id, :entry_id, presence: true
  validates :contest_id, uniqueness: true
  belongs_to :user
  belongs_to :entry
  belongs_to :contest

   before_create :generate_token

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Grant.exists?(token: random_token)
    end
  end
end
