# frozen_string_literal: true

class Common::RecordErrorsComponent < ViewComponent::Base
  def initialize(record:)
    @record = record
  end
end
