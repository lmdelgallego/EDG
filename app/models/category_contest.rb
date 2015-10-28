class CategoryContest < ActiveRecord::Base
	belongs_to :contest 
	belongs_to :category 
	validates :category_id, presence: true
	validates :contest, presence: true
end