# frozen_string_literal: true

class Common::LinkComponent < ViewComponent::Base
  def initialize(text:, link:, display_as_button: false, classes: "", options: {})
    @text = text
    @link = link
    @display_as_button = display_as_button
    @classes = classes
    @options = options
  end
end
