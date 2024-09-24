# frozen_string_literal: true

class Editor::GenreRowComponent < ViewComponent::Base
  def initialize(genre:)
    @genre = genre.decorate
  end
end
