class Admin::AdminsController < Admin::BaseController
  load_and_authorize_resource :admin
  before_action :set_admin, only: [:edit, :update, :destroy]
  
  def index
    @admins = @admins.all_except(current_admin).order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  def edit
  end

  def update
    if @admin.update(admin_params)
      if @admin.id == current_admin.id
        redirect_to admin_settings_path, notice: 'Your account was successfully updated.'
      else
        redirect_to admin_admins_path, notice: 'User was successfully updated.'
      end
    else
      flash.now[:notice] = @admin.errors.full_messages.join('. ')
      render :edit
    end
  end

  def destroy
    @admin.destroy
  end
  
  def profile_settings
    @admin = current_admin

    render template: "admin/admins/edit.html.erb"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_params
      params[:admin].delete(:password) if params[:admin][:password].blank?
      params[:admin].delete(:password_confirmation) if params[:admin][:password_confirmation].blank?

      params.require(:admin).permit(:email_frequency, :profile_image, :name, :email, :password, :password_confirmation, :remove_profile_image)
    end
end
