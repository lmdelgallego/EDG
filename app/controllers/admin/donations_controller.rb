class Admin::DonationsController < Admin::BaseController
  load_and_authorize_resource :donation
  
  def index
    @donations = Donation.successful.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end
end