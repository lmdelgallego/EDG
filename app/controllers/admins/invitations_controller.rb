class Admins::InvitationsController < Devise::InvitationsController

  # PUT /resource/invitation
  def update
    self.resource = accept_resource

    if resource.errors.empty?
      yield resource if block_given?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active                                                                                        
      set_flash_message :notice, flash_message
      sign_in(resource_name, resource)
      respond_with resource, :location => after_accept_path_for(resource)
    else
      flash.now[:notice] = resource.errors.full_messages.join('. ')
      respond_with_navigational(resource){ render :edit }
    end
  end

end