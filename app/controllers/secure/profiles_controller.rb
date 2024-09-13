class Secure::ProfilesController < Secure::BaseController
  skip_before_action :set_current_profile!

  def index
    @profiles = current_user.profiles
  end

  def new
    @profile = current_user.profiles.new
  end

  def create
    @profile = current_user.profiles.new(profile_params)

    if @profile.save
      redirect_to profiles_path
    else
      render :new
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name)
  end
end
