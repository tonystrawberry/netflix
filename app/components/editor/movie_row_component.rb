# frozen_string_literal: true

class Editor::MovieRowComponent < ViewComponent::Base
  def initialize(movie:)
    @movie = movie.decorate
  end
end
