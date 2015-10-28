class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :get_premium_account]
  before_action :set_user, only: [:show, :contests_won]
  before_action :set_current_user, except: [:show, :contests_won ]
  before_action :validate_password_if_present, only: [:update]
  before_action :set_studies, only: [:update]
  skip_before_filter :verify_complete_basic_info, :only =>[:autocomplete_alma_mater_name, :autocomplete_major_name, :autocomplete_minor_name]
  autocomplete :alma_mater, :name, full: true
  autocomplete :minor, :name, full: true
  autocomplete :major, :name, full: true
  #layout "new_frontend", only: [:show]

  # GET /users/1/
  def show
    flash.clear
    @entries = @user.entries.includes(:contest).most_recent.paginate(page: params[:page], per_page: 6)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def cancel_account
    current_user.membership.update(status: false)
    respond_to do |format|
      format.js
    end
  end
 
  # GET /users/1/edit
  def edit
    if @user.studies.empty?
        @studies = @user.studies.build
      end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      sign_in @user, :bypass => true if @pwd_change
      redirect_to user_path(@user), notice: 'User was successfully updated.'
    else
      flash.now[:notice] = @user.errors.full_messages.join('. ')
      render :edit
    end
  end

  def read_notifications
    @user.mark_notifications_as_read

    respond_to do |format|
      format.json { render json: "All read", status: :ok }
    end
  end

  def premium
    render layout: "devise"
  end

  def contests_won
    flash.clear
    @contests = @user.grants.map { |g| g.entry.contest }
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_current_user
      @user = current_user
    end

    def set_studies
       if params[:user][:studies_attributes].present?
        params[:user][:studies_attributes].each_value do |study|
          study[:graduation_date] = Date.strptime(study[:graduation_date], "%m-%Y") unless study[:graduation_date].blank?
          alma_id = AlmaMater.find_by_name(study[:alma_mater_id])
          if alma_id.nil?
            study.delete(:user_id)
            study.delete(:alma_mater_id)
            study.delete(:mijor_id)
            study.delete(:major_id)
            study.delete(:graduation_date)
            study.delete(:degree_id)
          else
            study[:alma_mater_id] = alma_id.id
            major_course = Major.find_by_name(study[:major_id])
            minor_course = Minor.find_by_name(study[:minor_id])
            if major_course.nil?
              study.delete(:major_id)
            else
              study[:major_id]= major_course.id
            end
            if minor_course.nil?
              study.delete(:minor_id)
            else
              study[:minor_id]= minor_course.id
            end
          end
        end
      end
    end

    def validate_password_if_present
      @pwd_change = false
      if params[:user][:password].present? && params[:user][:password_confirmation].present?
        if @user.valid_password?(params[:user][:current_password])
          params[:user].delete(:current_password)
          @pwd_change = true
        else
          flash.now[:notice] = "Ooops! Something was wrong with your current password."
          render :edit
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
    params[:user][:amount] = params[:user][:amount].delete("$").split(",").join('') if params[:user][:amount].present?
    params.require(:user).permit(:email_frequency, :profile_image,:profile_image_crop_x, :profile_image_crop_y, :profile_image_crop_w, :profile_image_crop_h, :email, :tax, :full_name, :street_address, :enrollment_status, :donor, :password, :current_password, :state_id, :zipcode, :username,
                                    :description, :password_confirmation, :address_2, :graduation_date, :amount, :degree_id, :major_course_id, :education_data, :personal_data, :city, :minor_course_id, :remove_profile_image, :alma_mater_per_users_attributes => [:id, :user_id, :alma_mater_id], :studies_attributes => [:alma_mater_id, :user_id, :id, :degree_id, :major_id, :minor_id, :graduation_date])
    end
end
