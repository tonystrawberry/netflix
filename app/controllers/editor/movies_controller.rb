class Editor::MoviesController < Editor::BaseController
  def index
    @movies = Movie.all
    @genres = Genre.all
  end

  def new
    @movie = Movie.new
    @genres = Genre.all
    @audiences = Movie.audience_types.keys
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      @audiences = Movie.audience_types.keys

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @movie = Movie.find(params[:id])
    @genres = Genre.all
    @audiences = Movie.audience_types.keys
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update(movie_params)
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      @audiences = Movie.audience_types.keys

      render :edit, status: :unprocessable_entity
    end
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :description, :released_on, :audience_type, :featured, :cover, :logo)
  end
end
