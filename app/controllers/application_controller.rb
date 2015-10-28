class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :configure_permitted_parameters, :get_referer_path_for_sign_in, if: :devise_controller?
  
  layout :layout_by_resource

  #before_filter :verify_complete_basic_info

  def verify_complete_basic_info
    if current_user
      if current_user.username.nil? || current_user.email.nil? || current_user.studies.count <1
        redirect_to user_basic_info_path
      end
    end
  end
  
  def after_sign_in_path_for(resource)
    if resource.class == User
      if resource.sign_in_count > 1
        if @referer_path.present?
          @referer_path
        else
          user_path(resource)
        end
      elsif resource.donor.nil?
        user_basic_info_path
      else
        contests_path
      end
    elsif resource.class == Admin
      admin_dashboard_path
    end
  end
  
  def after_sign_out_path_for(resource)
    if resource == "admin".to_sym
      new_admin_session_path
    else
      root_path
    end
  end

  def current_ability
    @current_ability ||= AdminAbility.new(current_admin)
  end
  
  # Only admins are Invitable
  def after_invite_path_for(resource)
    admin_admins_path
  end

  def get_referer_path_for_sign_in
    @referer_path = params[:referer_path]
  end

    protected

    def layout_by_resource
      if devise_controller? || params[:controller] == "users/registrations"
        if params[:controller] == "admins/invitations" && params[:action] == "new"
          "admin"
        else
          "devise"
        end
      else
        "application"
      end
    end
    
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :mode, :t_price, :tax, :username, :password, :password_confirmation, :full_name, :donor, :stripe_token) }
    end
    
end
