class Users::RegistrationsController < ApplicationController
  before_action :set_user, :authenticate_user!, except: [:winner_grant]
  before_action :validate_data, only: [:basic_info]
  before_action :validate_study_present, only: [:basic_info]
  before_action :validate_username_present, only: [:basic_info]
  skip_before_filter :verify_complete_basic_info
    
  def basic_info
    if request.patch?
      if @user.update(user_params)
        @user.update(slug: nil) unless @user.slug.nil?
        if @user.donor?
          if @referer_path
            redirect_to @referer_path, notice: 'Your info was successfully completed, thanks!'
          else
            redirect_to root_path, notice: 'Your info was successfully completed, thanks!'
          end
        else
           redirect_to root_path, notice: 'Your info was successfully completed, thanks!'
        end
      else
        flash.now[:notice] = @user.errors.full_messages.join('. ')
        render :basic_info
      end
    else
      if @user.studies.empty?
        @studies = @user.studies.build
      end
    end
  end

  def winner_grant
   @token = Grant.find_by_token(params[:token])
   @user2 = @token.user
   if current_user 
    unless current_user == @user2
      sign_out current_user
     redirect_to new_user_session_path(referer_path: request.path), notice: 'You must be logged in.'
    end
   else
    redirect_to new_user_session_path(referer_path: request.path), notice: 'You must be logged in.'
   end
  end 
  
  
  def school_info
    if request.patch?
      if @user.update(user_params)
        redirect_to root_path, notice: 'Your info was successfully completed, thanks!'
      else
        render :school_info
      end
    else
      @user.build_alma_mater_per_users if @user.alma_mater_per_users.nil?
    end
  end
  
  private
    def set_user
      @user = current_user
    end

    def validate_data
      @sw = false
      if request.patch? && params[:user][:studies_attributes].present?
        params[:user][:studies_attributes].each_value do |study|
          study[:graduation_date] = Date.strptime(study[:graduation_date], "%m-%Y") unless study[:graduation_date].blank?
          if alma_mater = AlmaMater.find_by_name(study[:alma_mater_id])
            study[:alma_mater_id] =alma_mater.id
            @sw = true
            if minor_course = Minor.find_by_name(study[:minor_id])
              study[:minor_id]= minor_course.id
            else
              study.delete(:minor_id)
            end
            if major_course = Major.find_by_name(study[:major_id])
              study[:major_id]= major_course.id
            else
              study.delete(:major_id)
            end
          else
            params[:user][:studies_attributes].delete(study)
          end
        end
      end
    end
  
    def validate_study_present
      if request.patch?  && !@sw
          flash.now[:notice] = "Ooops! Alma Mater can´t be blank."
          params[:user].delete(:studies_attributes)
          @studies = @user.studies.build if @user.studies.blank?
          @user.update(user_params)
          render :basic_info
      end
    end

    def validate_username_present
       if request.patch?  && @user.username.nil? && params[:user][:username]== ""
           @studies = @user.studies.build
          flash.now[:notice] = "Ooops! Username can´t be blank."
          render :basic_info
      end
    end


    def user_params
      params[:user][:amount] = params[:user][:amount].delete("$").split(",").join('')
      params.require(:user).permit(:profile_image, :email, :username, :street_address, :tax, :enrollment_status, :donor, :description, :degree_id, :major_course_id, :minor_course_id, :amount,
                                    :graduation_date, :address_2, :state_id, :city, :zipcode, :remove_profile_image, :stripe_token, :alma_mater_per_users_attributes => [:alma_mater_id, :user_id, :id], :studies_attributes => [:alma_mater_id, :user_id, :id, :degree_id, :major_id, :minor_id, :graduation_date, :_destroy])
    end
end
