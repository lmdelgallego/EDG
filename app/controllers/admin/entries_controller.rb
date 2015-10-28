class Admin::EntriesController < Admin::BaseController
  before_action :set_contest
  before_action :set_entry
  
  def destroy
    @entry.destroy
  end
  
  def mark_as_winner
    if @entry.mark_as_winner!
      NotificationsMailer.delay.winner_entry_user(@entry.grant)
    else
      render js: "Contest already has a winner"
    end
  end

  def undo_winner
    if @entry.undo_winner!
    else
      render js: "Winner could not be removed."
    end
  end

  def re_send_email
    NotificationsMailer.delay.winner_entry_user(@entry.grant)
    render js: "Email sent."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contest
      @contest = Contest.find(params[:contest_id])
    end
    
    def set_entry
      @entry = @contest.entries.find(params[:id])
    end
end