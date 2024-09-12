class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale
  before_action :redirect_to_home, if: -> { user_signed_in? && !controller_path.start_with?('secure/') }

  private

  # Switch the locale for the current request.
  def switch_locale(&action)
    @current_locale = params[:locale] || I18n.default_locale
    I18n.with_locale(@current_locale, &action)
  end

  # Redirect to the browse page if the user is already signed in.
  def redirect_to_home
    redirect_to browse_path
  end
end
