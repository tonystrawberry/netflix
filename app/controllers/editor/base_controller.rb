class Editor::BaseController < ApplicationController
  around_action :switch_locale

  private

  # Switch the locale for the current request.
  def switch_locale(&action)
    @current_locale = params[:locale] || cookies[:locale] || I18n.default_locale

    cookies[:locale] = params[:locale] if params[:locale].present?

    I18n.with_locale(@current_locale, &action)
  end
end
