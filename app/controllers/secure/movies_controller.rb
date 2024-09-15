class Secure::MoviesController < Secure::BaseController
  def index
    @genres = Genre.all
  end
end
