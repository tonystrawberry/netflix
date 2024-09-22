# frozen_string_literal: true

class Welcome::LocaleSelectorComponent < ViewComponent::Base
  def initialize(available_locales:, current_locale:)
    @available_locales = available_locales
    @current_locale = current_locale
  end
end
