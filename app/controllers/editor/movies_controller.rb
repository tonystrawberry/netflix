class Editor::MoviesController < Editor::BaseController
  def index
    @genres = Genre.all
  end
end
