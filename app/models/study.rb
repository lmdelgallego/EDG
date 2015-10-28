class Study < ActiveRecord::Base
  belongs_to :user
  belongs_to :alma_mater
  belongs_to :degree
  belongs_to :major
  belongs_to :minor
  validates :alma_mater_id, presence: true
end
