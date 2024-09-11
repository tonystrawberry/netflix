# frozen_string_literal: true

class FlashAlertComponent < ViewComponent::Base
  def initialize(type:, message:)
    @type = type
    @message = message
  end

  private

  # Returns TRUE if the flash type is "notice"
  # @return [Boolean]
  def is_notice_flash?
    @type == "notice"
  end

  # Returns TRUE if the flash type is "alert"
  # @return [Boolean]
  def is_alert_flash?
    @type == "alert"
  end
end
