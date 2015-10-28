class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :get_donor, :get_referer
  
  def facebook
    oauthorize('facebook')
  end
  
  def twitter
    oauthorize('twitter')
  end
  
  def linkedin
    oauthorize('linkedin')
  end
  
  def google
    oauthorize('google')
  end
  
  private
  
    def get_donor
      @donor = request.env["omniauth.params"]["donor"]
      puts @donor
    end

    def get_referer
      @referer_path = request.env["omniauth.params"]["referer_path"]
    end
  
    def oauthorize(provider)
      puts request.env["omniauth.auth"]
      if user_signed_in?
        # We will connect an account to the current_user
        @user = current_user
        puts request.env["omniauth.auth"]
        @user.connect_omniauth_account(request.env["omniauth.auth"])

        if @user.save
          redirect_to user_path(@user), notice: "Account connected successfully"
        else
          redirect_to edit_user_profile_path, notice: "Oops! #{@user.errors.full_messages.join('. ')}"
        end
      else
        # We will create a new user with the omniauth data
        @user = User.from_omniauth(request.env["omniauth.auth"], @donor)
        if @user.persisted?
          if @donor 
            sign_in @user
            redirect_to edit_membership_path(@user.membership), :event => :authentication #this will throw if @user is not activated

          else
            if  @user.sign_in_count >= 1
              sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            else
              sign_in @user
              redirect_to user_basic_info_path, :event => :authentication
            end
          end
        else
          puts @user.errors.full_messages.join('. ')
          redirect_to new_user_registration_url, notice: @user.errors.full_messages.join('. ')
        end
      end
    end
end