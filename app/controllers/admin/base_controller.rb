class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"
  
  def current_ability
    @current_ability ||= AdminAbility.new(current_admin)
  end
end