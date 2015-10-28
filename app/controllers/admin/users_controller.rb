class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource :user
  before_action :set_user, only: [:edit, :update, :destroy, :mark_as_premium]
  before_action :get_payment_status, only: [:index]

  # GET /users
  def index
    if params[:search]
      @users = @users.name_is_like(params[:search]).order('created_at DESC').paginate(page: params[:page], per_page: 8)
    elsif @payment_status
      @users = @users.premium.order('created_at DESC').paginate(page: params[:page], per_page: 8) if @payment_status == 'true'
      @users = @users.free.order('created_at DESC').paginate(page: params[:page], per_page: 8) if @payment_status == 'false'
    else
      @users = @users.order('created_at DESC').paginate(page: params[:page], per_page: 8)
    end
  end

  # GET /users/1/edit
  def edit
    if @user.alma_mater_per_users.empty?
      alma_mater_per_users = @user.alma_mater_per_users.build
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User was successfully updated.'
    else
      flash.now[:notice] = @user.errors.full_messages.join('. ')
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def mark_as_premium
    @user.mark_as_premium
    @user.membership.update(plan_id: 2, expiration_date: nil)
    NotificationsMailer.delay.premium_account(@user)
    redirect_to :back
  end
  
  def remove_premium
    @user.update_attribute(:premium, false)
    @user.membership.update_attribute(:plan_id, 1)
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def get_payment_status
      if params[:payment_status].present?
        @payment_status = params[:payment_status] if ['true', 'false'].include?(params[:payment_status])
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      
      
      params[:user].delete(:password) if params[:user][:password].blank?
      params[:user].delete(:password_confirmation) if params[:user][:password_confirmation].blank?

      params[:user][:amount] = params[:user][:amount].delete("$").split(",").join('')
      params[:user][:graduation_date] = DateTime.strptime(params[:user][:graduation_date], "%m/%Y") unless params[:user][:graduation_date].blank?

      params.require(:user).permit(:profile_image, :username, :email, :full_name, :street_address, :enrollment_status, :donor, :password, :description, :password_confirmation, :graduation_date, :remove_profile_image, :degree_id, :amount, :major_course_id, :minor_course_id, :alma_mater_per_user_attributes => [:id, :alma_mater_id, :user_id])
    end
end
