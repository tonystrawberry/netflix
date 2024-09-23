class Editor::MoviesController < Editor::BaseController
  def index
    @movies = Movie.all
    @genres = Genre.all
  end

  def new
    @movie = Movie.new
    @genres = Genre.all
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      render :new
    end
  end

  def edit
    @movie = Movie.find(params[:id])
    @genres = Genre.all
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update(movie_params)
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      render :edit
    end
  end
end
