class DonationsController < ApplicationController
  before_action :set_donation, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:index]

  # GET /donations
  def index
    @user = current_user
    @donations = @user.donations.order("created_at DESC")
  end

  # GET /donations/1
  def show
  end

  # GET /donations/new
  def new
    @donation = Donation.new
  end

  # GET /donations/1/edit
  def edit
  end

  # POST /donations
  def create
    @donation = Donation.new(donation_params)
    @donation.user = current_user
    
    respond_to do |format|
      if @donation.save_with_payment
        #NotificationsMailer.delay.new_donation_user(@donation.user)
        #NotificationsMailer.delay.new_donation_superadmin
        format.js
      else
        @errors = @donation.errors.full_messages.join('. ')
        format.js { render :template => "donations/errors.js.erb" }
      end
    end

  end

  # PATCH/PUT /donations/1
  def update
    if @donation.update(donation_params)
      redirect_to @donation, notice: 'Donation was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /donations/1
  def destroy
    @donation.destroy
    redirect_to donations_url, notice: 'Donation was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_donation
      @donation = Donation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def donation_params
      params[:donation][:amount] = params[:donation][:amount].delete("$").split(",").join('')
      params.require(:donation).permit(:amount, :status, :user_id, :stripe_token, :anonymous)
    end
end
