class Admin::DashboardController < Admin::BaseController
  load_resource :contest, :parent => false
  load_resource :user, :parent => false
  load_resource :entry, :parent => false
  load_resource :donation, :parent => false
  
  def index
    @visitors_count = Contest.total_visitors
    @entries_count = @entries.count
    @recent_users = @users.where("created_at >= ?", 1.week.ago).order("created_at DESC")
    @recent_contests = @contests.active.order('created_at DESC').limit(3)
    @recent_donations = @donations.this_week.order('created_at DESC')
    @total_contests = @contests.pluck(:id)
    @recent_activities = PublicActivity::Activity.where("trackable_type = ? AND trackable_id IN (?) AND created_at >= ?", "Contest", @total_contests, 1.week.ago).order("created_at DESC")
  end

end