class UpvotesController < ApplicationController
  before_action :set_upvote, only: [:create]

  def new
    @upvote = Upvote.new
  end

  # POST /upvotes
  def create
    # @upvote = Upvote.new(upvote_params)
    @upvote.user = current_user
    @upvote = @upvote.user.new(upvote_params)

    if @upvote.save
      redirect_to @upvote, notice: 'Upvote was successfully created.'
    else
      render :new
    end
  end

  # DELETE /upvotes/1
  def destroy
    @upvote.destroy
    redirect_to upvotes_url, notice: 'Upvote was successfully destroyed.'
  end

  private
    def set_upvote
      @upvote = Upvote.find(params[:id])
    end
    # Only allow a trusted parameter "white list" through.
    def upvote_params
      params.require(:upvote).permit(:entry_id,:user_id)
    end
end
