class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale

  def switch_locale(&action)
    @current_locale = params[:locale] || I18n.default_locale
    I18n.with_locale(@current_locale, &action)
  end
end
