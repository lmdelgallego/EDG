class MembershipsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new]
  before_action :set_membership, only:[:update, :edit]
  
  skip_before_filter :verify_complete_basic_info

  # GET /memberships/1/edit
  def edit
    @referer_path = params[:referer_path]
    puts @plan.price
    puts @plan.anual_price
  end


  def update
    if @membership.update(membership_params)
      @membership.user_id = current_user.id
      @membership.user_email = current_user.email
      @membership.save
      @membership.user.mark_as_premium  
      if @referer_path
        redirect_to @referer_path , notice: 'Premium Account successfully created.'
      else
        if @membership.user.sign_in_count <= 1 && current_user.studies.count < 1
          redirect_to user_basic_info_path, notice: 'Premium Account successfully created.'
        else
          redirect_to @membership.user, notice: 'Premium Account successfully created.'
        end
      end
    else
      flash.now[:notice] =  @membership.errors.full_messages.join('. ')
      redirect_to new_membership_path
    end
  end

 
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
       @plan = Plan.find_by_name('Premium')
    end


    # Only allow a trusted parameter "white list" through.
    def membership_params
      params.require(:membership).permit(:user_id, :stripe_customer_id, :mode, :status, :expiration_date, :stripe_token, :referer_path)
    end
end
