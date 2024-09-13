class Secure::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_profile!

  private

  # Set the profile for the current user.
  def set_current_profile!
    @current_profile = current_user.profiles.find_by(code: @profile_code)

    redirect_to profiles_path if @current_profile.nil?
  end
end
