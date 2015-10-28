class ContestsController < ApplicationController
  before_action :set_contest, only: [:show, :edit, :update, :destroy, :get_caption_image, :on_watch_list, :off_watch_list]
  before_action :get_type, only: [:index]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :get_caption_image, :on_watch_list, :off_watch_list]
  autocomplete :user, :username, full: true
  skip_before_filter :verify_complete_basic_info, only: [:autocomplete_user_username]
  layout "new_frontend", only: [:show]

  # GET /contests
  def index
    @contests = Contest.contest_filter(@contest_type,@contest_status,@contest_premium,params[:page])
  end

  # GET /contests/1
  def show
    @entry_attachment = EntryAttachment.new
    @entry = Entry.new
    if @contest.has_winner?
      @entries = @contest.entries.winner_first.paginate(page: params[:page], per_page: 6)
    else
      @entries = @contest.entries.most_recent.paginate(page: params[:page], per_page: 6)
    end
    ahoy.track "Viewed contest #{@contest.id}"

    @visits = @contest.visits_count

    if @contest.entries.any?
      @last_entry_user = @contest.entries.last.user
      @most_voted_entry = @contest.entries.most_upvotes.first if @contest.entries.most_upvotes.first.upvotes.count > 0
    end

    @similar_contests = Contest.similar_contests(@contest.categories.first.name).not_include(@contest).limit(4)
  end

  # GET /contests/new
  def new
    @contest = Contest.new
  end

  # POST /contests
  def create
    @contest = Contest.new(contest_params)

    if @contest.save
      redirect_to @contest, notice: 'Contest was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /contests/1
  def update
    if @contest.update(contest_params)
      redirect_to @contest, notice: 'Contest was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contests/1
  def destroy
    @contest.destroy
    redirect_to contests_url, notice: 'Contest was successfully destroyed.'
  end

  def get_caption_image
    if @contest.categories.include?('caption') && @contest.caption_image.present?
      @caption_image = @contest.caption_image.path
      send_file @caption_image, :type => 'image/jpeg', disposition: 'attachment'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def on_watch_list
    current_user.watch_lists.build(contest: @contest)
    current_user.save
  end

  def off_watch_list
    current_user.contests.delete(@contest)
    current_user.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contest
      @contest = Contest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def contest_params
      params.require(:contest).permit(:name, :contest_type, :description, :judging_criteria, :additional_details, :start_date, :end_time, :reward, :premium, :sponsor, :status, :private, :admin_id)
    end

    def get_type
      if params[:type].present?
        @contest_type = params[:type] if ['text', 'image', 'audio', 'caption', 'video'].include?(params[:type])
      else
        @contest_type = ""
      end
      if params[:status].present?
        @contest_status = params[:status] if ['active', 'closed'].include?(params[:status])
        @contest_status = ['finished', 'closed'] if @contest_status == "closed"
      else
        @contest_status = 'active'
      end
      if params[:premium].present?
        @contest_premium = params[:premium].to_i if ['1', '0'].include?(params[:premium])
      else
        @contest_premium = ""
      end
    end

end
