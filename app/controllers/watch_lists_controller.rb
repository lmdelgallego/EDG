class WatchListsController < ApplicationController
  before_action :set_watch_list, only: [:show, :edit, :update, :destroy]

  # GET /watch_lists
  def index
    @watch_lists = WatchList.all
  end

  # GET /watch_lists/1
  def show
  end

  # GET /watch_lists/new
  def new
    @watch_list = WatchList.new
  end

  # GET /watch_lists/1/edit
  def edit
  end

  # POST /watch_lists
  def create
    @watch_list = WatchList.new(watch_list_params)

    if @watch_list.save
      redirect_to @watch_list, notice: 'Watch list was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /watch_lists/1
  def update
    if @watch_list.update(watch_list_params)
      redirect_to @watch_list, notice: 'Watch list was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /watch_lists/1
  def destroy
    @watch_list.destroy
    redirect_to watch_lists_url, notice: 'Watch list was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_watch_list
      @watch_list = WatchList.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def watch_list_params
      params.require(:watch_list).permit(:user_id_id, :contest_id_id)
    end
end
