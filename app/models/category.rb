class Category < ActiveRecord::Base

  validates :name, presence: true, inclusion: { in: %w(image audio caption text video) }
  has_many :category_contests
  has_many :contests, through: :category_contests
  has_many :entry_attachments

end
