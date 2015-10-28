module UsersHelper
  def html_class_for_provider(provider)
    case provider
    when "facebook"
      "fb"
    when "google"
      "gp"
    when "twitter"
      "tw"
    when "linkedin"
      "lkdn"
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end