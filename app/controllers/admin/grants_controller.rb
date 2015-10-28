class Admin::GrantsController < Admin::BaseController
  before_action :set_grant, only: [:show]
  # GET /grants
  def index
    @grants = Grant.paginate(:page => params[:page], :per_page => 10)
  end

  # GET /grants/1
  def show
    @user = @grant.user
  end

 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grant_params
      params.require(:grant).permit(:user_id, :entry_id, :status)
    end
end
