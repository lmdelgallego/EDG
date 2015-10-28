class PagesController < ApplicationController
  before_action :get_type, only: [:home]
  layout "admin", only: [:dashboard, :users, :admins, :contestadmin]
  layout "new_frontend", only: [:home, :search, :about, :help]

  def home
    # All contests using method optional arguments
    @contests = Contest.contest_filter(@contest_type,@contest_status,@contest_premium,params[:page], @order)
    @entries = Entry.where(winner: true).most_recent.limit(6)
    @fav_contests = Contest.where(fav_at_home: true).limit(6)
    puts "favs contest"
    puts @fav_contests
  end

  def about
  end

  def help
  end

  def privacy
  end

  def webmail
    render layout: false
  end

  def contact_us
    if request.post?
      name = params[:name]
      email = params[:email]
      message = params[:message]
      # We need a real contact email
      # contact_email = Admin.where(super: true).first.email
      #NotificationsMailer.delay.new_contact_message(contact_email, email, name, message)
      redirect_to root_path, notice: 'Your message was successfully sent, thanks!'
    end
  end

  def search
    @results = SearchResult.where("content like ?","%#{params[:search]}%").paginate(page: params[:page], per_page: 6)
  end

  private

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

      @order =  params[:order].present? ? params[:order] : ""
    end

end
