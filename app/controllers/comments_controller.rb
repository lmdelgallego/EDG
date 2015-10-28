class CommentsController < ApplicationController
  before_action :set_entry
  before_action :set_comment, only: [:destroy]

  # POST /comments
  def create
    @comment = @entry.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to contest_entry_url(@entry.contest, @entry), notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      redirect_to @comment, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
    redirect_to contest_entry_url(@entry.contest, @entry), notice: 'Comment was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params[:entry_id])
    end
    
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:message)
    end
end
