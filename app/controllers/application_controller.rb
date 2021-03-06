require 'json_web_token'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include SessionsHelper
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Validates the token and user, and then sets the @current_user scope
  def authenticate_request!
    if !payload || !JsonWebToken.valid_payload(payload.first)
      return invalid_authentication
    end
    load_current_user!
    invalid_authentication unless @client_current_user
  end

  # Returns 401 response. To handle malformed /invalid requests.
  def invalid_authentication
    render json: {error: 'Invalid Request'}, status: :unauthorized
  end

  # Return the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end

  end

  #Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end
  helper_method :current_user?

  helper_method :current_user

  helper_method :authenticate_request!

  def superadmin_or_admin?(user)
    superadminProfile = Profile.find_by!(name: "superadmin")
    adminProfile = Profile.find_by!(name: "admin")
    user.profiles.include?(superadminProfile) || user.profiles.include?(adminProfile)
  end

  helper_method :superadmin_or_admin?



  private
  def user_not_authorized
    flash[:warning] = "You are not authorized to perform this action"
    redirect_to(request.referrer || root_path)
  end

  # Deconstructs the Authorization header and decodes the JWT
  def payload
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last
    JsonWebToken.decode(token)
  rescue
    nil
  end

  def load_current_user!
    @client_current_user =User.find_by(id: payload[0]['user_id'])
  end
end
