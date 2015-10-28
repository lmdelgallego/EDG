require 'uri'

module ApplicationHelper
  def is_donor?(user)
    params[:donor] == "true" || user.donor?
  end

  def entry_picture_url(entry)
    case entry.contest.categories.first.name
    when "caption"
      if Rails.env.development? || Rails.env.test?
        (URI.parse(root_url) + entry.contest.caption_image.url).to_s
      end
    when "image"
      if Rails.env.development? || Rails.env.test?
        image_url = entry.entry_attachments.where(category_id: 1).first
        (URI.parse(root_url) + image_url.attachment.url).to_s
      end
    when "audio"
      image_url("misc/audio1.png")
    when "text"
      image_url("misc/text1.png")
    when "video"
      "http://img.youtube.com/vi/#{entry.video_url_format}/0.jpg"
    end
  end

  def contest_time_left(contest)
    case contest.status
    when "active", "paused"
      "#{distance_of_time_in_words(Time.zone.now, contest.end_time, false, { highest_measure_only: true })} left"
    when "closed"
      "Ended"
    when "pending"
      "Not started yet"
    end
  end

  def contest_status(contest)
    if contest.status == "active" || contest.status == "paused"
      "#{distance_of_time_in_words(Time.zone.now, contest.end_time, false, { highest_measure_only: true })} left"
    elsif contest.status == "closed"
        "Closed"
    elsif contest.status =="finished"
        "Finished"
    end
  end

  def contest_status_class(contest)
    contest.closed? ? "finished" : ""
  end

  def entry_type_image(entry)
    type = entry.contest.categories.first.name
    resp = ""
    case type
    when 'image'
      resp = entry.entry_attachments.where(category_id: 1).first.attachment.url unless entry.entry_attachments.where(category_id: 1).first.nil?
    when 'audio'
      resp = 'misc/audio1.png'
    when 'text'
      resp = 'misc/text1.png'
    when 'caption'
      resp = entry.contest.caption_image.url
    when 'video'
      resp = 'misc/audio1.png'
    end
    resp
  end
  
  def days_count(dtime)
    mm, ss = dtime.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    dd
  end

  def contest_time_status(end_time)
    t = distance_of_time_in_words_hash(Time.zone.now, end_time)
    r = "green"
    if  t["months"].nil? && t["days"].nil? && t["years"].nil?
      r = t["hours"] <= 4 ? "red" :  "orange"
    end
    r
  end
end
