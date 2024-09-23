# frozen_string_literal: true

class Secure::HeaderComponent < ViewComponent::Base
  def initialize(profile:)
    @profile = profile
  end
end
