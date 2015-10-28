class AlmaMaterPerUser < ActiveRecord::Base
	validates  :alma_mater_id, :user_id, presence: true
  belongs_to :user
  belongs_to :alma_mater
end
