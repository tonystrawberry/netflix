class Secure::MoviesController < Secure::BaseController
  def index
    @genres = Genre.includes(:movies)

    @movies = @genres.each_with_object({}) do |genre, hash|
      hash[genre] = genre.movies
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end
end
