require 'open-uri'

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
    @profile.language = I18n.locale

    if @profile.save
      unless @profile.avatar.attached?
        downloaded_random_avatar = OpenURI.open_uri("https://avatar.iran.liara.run/public")
        @profile.avatar.attach(io: downloaded_random_avatar, filename: "avatar_#{@profile.code}.jpg")
      end

      redirect_to profiles_path
    else
      render :new
    end
  end

  def show
    @profile = current_user.profiles.find_by!(code: params[:code])
  end

  def select
    profile = current_user.profiles.find_by!(code: params[:code])
    cookies.signed[:profile_code] = profile.code

    redirect_to movies_path
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :avatar)
  end
end
