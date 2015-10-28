class Admin::PlansController < Admin::BaseController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  def index
    @plans = Plan.all
  end

  def edit

  end

  def update
    if @plan.update(plan_params)
      redirect_to admin_plans_path , notice: 'Successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @plan.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      params[:plan][:price] = params[:plan][:price].delete("$").split(",").join('') if params[:plan][:price].present?
      params[:plan][:anual_price] = params[:plan][:anual_price].delete("$").split(",").join('') if params[:plan][:anual_price].present?
      params.require(:plan).permit( :name, :price, :number_of_entries, :anual_price)
    end

end