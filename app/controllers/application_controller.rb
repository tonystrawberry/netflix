class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  around_action :switch_locale
  before_action :redirect_to_home, if: -> { user_signed_in? && !controller_path.start_with?("secure/") }
  before_action :redirect_to_editor_home, if: -> { administrator_signed_in? && !controller_path.start_with?("editor/") }

  private

  # Switch the locale for the current request.
  def switch_locale(&action)
    @current_locale = params[:locale] || cookies[:locale] || I18n.default_locale

    cookies[:locale] = params[:locale] if params[:locale].present?

    I18n.with_locale(@current_locale, &action)
  end

  # Redirect to the browse page if the user is already signed in.
  def redirect_to_home
    redirect_to movies_path
  end

  # Redirect to the editor page if the administrator is already signed in.
  def redirect_to_editor_home
    redirect_to editor_movies_path
  end
end
