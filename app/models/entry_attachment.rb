class EntryAttachment < ActiveRecord::Base
	mount_uploader :attachment, EntryAttachmentUploader
	mount_uploader :audio_attachment, AudioEntryAttachmentUploader
	belongs_to :entry
	belongs_to :category
	validates_presence_of :audio_attachment, :if => Proc.new{|f| f.category_id == 2 }, :on => :create
	validates_presence_of :attachment, :if => Proc.new{|f| f.category_id == 1 }, :on => :create


end
