class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :upvote, :entry_edit]
  before_action :set_contest
  before_action :authenticate_user!, only: [:new, :create, :upvote, :update, :set_user]
  
  # GET /entries
  def index
    if params[:order_by] == 'upvotes'
      @entries = @contest.entries.most_upvotes
    else
      @entries = @contest.entries.most_recent
    end
    @entries = @entries.paginate(page: params[:page], per_page: 6)
  end

  # GET /entries/1
  def show
    @comment = Comment.new
    @comments = @entry.comments.recent
    @index = @contest.entries.rindex(@entry)
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /entries/new
  def new
    @entry_attachment = EntryAttachment.new
    @entry = Entry.new
    # @entry_attachment = @entry.entry_attachments.build

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  # GET /entries/1/edit
  def edit
    @attachments = @entry.entry_attachments.build if @contest.multiple_images == 1
  end

  # POST /entries
  def create
    if params[:entry][:entry_attachments_attributes].present? && @contest.multiple_images == 1
     cant = params[:entry][:entry_attachments_attributes]["0"]["attachment"].count
     @images = params[:entry][:entry_attachments_attributes]["0"]["attachment"]
     params[:entry].delete(:entry_attachments_attributes)
    end
    @entry = @contest.entries.new(entry_params)
    @entry.user = current_user
    respond_to do |format|
      if @entry.save
        if @images.present?
          @images.each do |a|
            @entry_attachment = EntryAttachment.create!(entry_id: @entry.id, :attachment => a,category_id: 1)
          end
        end
        @entry.reload
        @contest.reload
        @contest.create_activity key: 'entry.created', owner: current_user, params: { entry_id: @entry.id }
        #NotificationsMailer.delay.new_contest_entry_participant(@contest, @entry)
        format.js
      else
        @errors = @entry.errors.full_messages.join('. ')
        format.js { render :template => "entries/errors.js.erb" }
      end
    end
  end

  def entry_edit 
  end

  # PATCH/PUT /entries/1
  def update
    @entry.update_nested_attributes(params[:entry][:entry_attachments_attributes])
    if @entry.update!(entry_params)
      redirect_to current_user, notice: 'Entry was successfully updated.'
    else
      flash[:notice] = @contest.errors.full_messages.join('. ')
      redirect_to @entry.user
    end
  end

  # DELETE /entries/1
  def destroy
    @entry.destroy
    redirect_to entries_url, notice: 'Entry was successfully destroyed.'
  end
  
  def upvote
    @upvote = @entry.upvotes.new
    @upvote.user = current_user
    
    respond_to do |format|
      if @upvote.save!
        @entry.user.create_activity key: 'entry.voted', owner: @entry, params: { user_id: current_user.id }
        format.js
      else
        format.js
      end
    end
  end

  private
    def set_user
      @user = current_user.id
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_contest
      #@contest = Contest.find(params[:contest_id])
      if @entry
      @contest = @entry.contest
      else
        @contest= Contest.find(params[:contest_id])
      end
    end
    
    def set_entry
      #@entry = @contest.entries.find(params[:id]) 
      @entry = Entry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entry_params
      params.require(:entry).permit(:name, :description, :upvotes_count, :contest_id, :user_id, :video_url, :body, entry_attachments_attributes: [:id, :entry_id, :attachment, :audio_attachment, :category_id, :_destroy])
    end
end
