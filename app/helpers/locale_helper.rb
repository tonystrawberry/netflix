module LocaleHelper
  # Returns an array of available locales for the application in the format:
  # [
  #   ["English", :en],
  #   ["日本語", :ja]
  # ]
  # @return [Array<Array<String, Symbol>>]
  def available_locales
    I18n.available_locales.map do |locale|
      [ I18n.t("locales.#{locale}"), locale ]
    end
  end
end
