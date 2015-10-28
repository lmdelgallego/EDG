# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
    storage :fog
  
  process :auto_orient
  
  version :main, if: :is_user_profile_pic? do
    process resize_to_fit: [370, nil], if: :is_landscape?
    process resize_to_fit: [nil, 280], if: :is_portrait?
  end
  
  version :thumb, if: :is_user_profile_pic? do
    process resize_to_limit: [35, nil]
  end
  
  version :mini, if: :is_contest_cover? do
    process resize_to_fit: [nil, 280]
  end

  version :cover, if: :is_contest_cover? do
    process resize_to_fit: [nil, 648]
  end

  version :mini_avatar, if: :is_contest_cover? do
    process resize_to_fit: [nil, 100]
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png )
  end

  protected
  
  def is_landscape? (picture)
    if @file
      image = ::MiniMagick::Image::read(File.binread(@file.file))
      image[:width] > image[:height]
    end
  end
  
  def is_portrait? (picture)
    if @file
      !is_landscape?(picture)
    end
  end
  
  def is_admin_profile_pic? (picture)
    model.class.to_s.underscore == "admin"
  end
  
  def is_user_profile_pic? (picture)
    model.class.to_s.underscore == "user"
  end
  
  def is_contest_cover? (picture)
    model.class.to_s.underscore == "contest" && mounted_as.to_s == "cover_photo"
  end

  def is_contest_caption? (picture)
    model.class.to_s.underscore == "contest" && mounted_as.to_s == "caption_image"
  end

  def auto_orient
    manipulate! do |img|
      img.auto_orient
      img = yield(img) if block_given?
      img
    end
  end
end
