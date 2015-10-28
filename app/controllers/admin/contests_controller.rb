class Admin::ContestsController < Admin::BaseController
  load_and_authorize_resource :except => [:create]
  before_action :set_contest, only: [:show, :edit, :destroy, :pause, :resume, :share_private_contest, :mark_as_favorite, :unmark_as_favorite]
  before_action :get_type, only: [:index]
  before_action :change_date_format, only: [:create, :update]
  before_action :set_categories, only: [:create]
  skip_before_filter :verify_complete_basic_info


  # GET /contests
  def index
    @contests = Contest.contest_filter_admin(@contest_type,@contest_status,@contest_premium,params[:page])
  end

  # GET /contests/1
  def show
    @visitors = @contest.visitors_count
    @entries = @contest.entries.order('upvotes_count DESC').paginate(page: params[:page], per_page: 15)
  end

  # GET /contests/new
  def new
    @contest = Contest.new
    @categories = @contest.category_contests.build
  end

  # GET /contests/1/edit
  def edit
    @contest.category_contests.build if @contest.category_contests.empty?

    if @contest.has_winner?
      redirect_to admin_contests_path, notice: "Close contests cannot be edited."
    end
  end

  # POST /contests
  def create
    @contest = Contest.new(contest_params)
    @contest.admin = current_admin
    if @contest.save
      @categories.each do |c|
        CategoryContest.create!(contest_id: @contest.id, category_id: c) unless c == ""
      end
      redirect_to admin_contest_path(@contest), notice: 'Contest was successfully created.'
    else
     @categories = @contest.category_contests.build
     render :new
    end
  end

  # PATCH/PUT /contests/1
  def update
    if @contest.update(contest_params)
      redirect_to admin_contest_path(@contest), notice: 'Contest was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /contests/1
  def destroy
    @contest.destroy
    respond_to do |format|
      format.html { redirect_to admin_contests_path, notice: "Contest successfully deleted" }
      format.js
    end
  end

  def pause
    @contest.pause!
    respond_to do |format|
      format.html { redirect_to admin_contest_path(@contest), notice: "Contest paused" }
      format.js
    end
  end

  def resume
    @contest.resume!
    respond_to do |format|
      format.html { redirect_to admin_contest_path(@contest), notice: "Contest resumed" }
      format.js
    end
  end

  def share_private_contest
  end

  def share_private_email

    @message = params[:email][:message]
    users = params[:email][:username].first.split(',')
    e = ""
    users.each do |u|
      @user = User.find_by_username(u)
      if @user
        NotificationsMailer.delay.share_private_contest(@message, @user.username, @user.email, @contest)
      else
        e += "#{u}, "
      end
    end

    notice =  e == "" ? 'Emails sent' : "#{e} not found"

    redirect_to admin_contest_path(@contest), notice: notice


  end

  def mark_as_favorite
   @contest.update(fav_at_home: true)
  end

  def unmark_as_favorite
   @contest.update(fav_at_home: false)
  end



  private

    # Open /Close
    def get_type
      if params[:type].present?
        @contest_type = params[:type] if ['text', 'image', 'audio', 'caption', 'video'].include?(params[:type])
      else
        @contest_type = ""
      end
      if params[:status].present?
        @contest_status = params[:status] if ['active', 'closed','pending','finished'].include?(params[:status])
      else
        @contest_status = 'active'
      end
      if params[:premium].present?
        @contest_premium = params[:premium].to_i if ['1', '0'].include?(params[:premium])
      else
        @contest_premium = ""
      end
    end
    # Use callbacks to share common setup or constraints between actions.

    def set_contest
      @contest = Contest.find(params[:id])
    end

    def change_date_format
      if params[:contest][:end_time].present?
        date_string = "#{params[:contest][:start_date]} #{params[:contest][:start_hour]}"
        date_string2 = "#{params[:contest][:end_time]} #{params[:contest][:end_hour]}"

        params[:contest][:start_date] = set_to_pst(date_string)
        params[:contest][:end_time] = set_to_pst(date_string2)
      else

        flash.now[:notice] = "Ooops! Something was wrong with your end date."
        @contest = Contest.new(name: params[:contest][:name], description:  params[:contest][:description], judging_criteria:  params[:contest][:judging_criteria], additional_details:  params[:contest][:additional_details], reward:  params[:contest][:reward], sponsor:  params[:contest][:sponsor])
        @categories = @contest.category_contests.build
        render :new
      end

    end

     def set_to_pst(date_string)
      date = DateTime.strptime(date_string,"%m-%d-%Y %H:%M:%S").strftime("%Y-%m-%d %H:%M:%S")
      ActiveSupport::TimeZone["Pacific Time (US & Canada)"].parse(date).in_time_zone("UTC")
     end

    def set_categories
      @categories = params['contest']['category_contests_attributes']['0']['category_id']
      if @categories.length <= 1
        flash.now[:notice] = "You must select a category."
        @contest = Contest.new(name: params[:contest][:name], description:  params[:contest][:description], judging_criteria:  params[:contest][:judging_criteria], additional_details:  params[:contest][:additional_details], reward:  params[:contest][:reward], sponsor:  params[:contest][:sponsor], sponsor_photo:  params[:contest][:sponsor_photo], sponsor_url:  params[:contest][:sponsor_url], sponsor_desc:  params[:contest][:sponsor_desc])
        @categories = @contest.category_contests.build
        render :new
      end
    end

    # Only allow a trusted parameter "white list" through.
    def contest_params

      params[:contest][:reward] = params[:contest][:reward].delete("$").split(",").join('') if params[:contest][:reward].present?
      params.require(:contest).permit(:name, :end_hour, :start_hour, :description, :judging_criteria, :additional_details, :start_date, :caption_image, :premium,
                                      :end_time, :reward, :sponsor, :sponsor_photo, :sponsor_url, :sponsor_desc, :show_image, :status, :private, :admin_id, :cover_photo, :show_entry_user_name, :max_entries_per_user, :descriptionl,
                                       :multiple_images, :banner_photo, :fav_at_home, :cover_m_photo, :show_image_on_entry )
    end
end
