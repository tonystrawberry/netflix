class Secure::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!
  around_action :switch_locale

  private

  # Set the profile for the current user.
  def set_current_profile!
    @profile_code = cookies.signed[:profile_code]
    @current_profile = current_user.profiles.find_by(code: @profile_code)

    redirect_to profiles_path if @current_profile.nil?
  end

  # Switch the locale for the current request.
  def switch_locale(&action)
    @current_locale = @current_profile&.language || params[:locale] || cookies[:locale] || I18n.default_locale
    I18n.with_locale(@current_locale, &action)
  end
end
