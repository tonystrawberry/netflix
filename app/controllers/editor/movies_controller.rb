class Editor::MoviesController < Editor::BaseController
  def index
    @movies = Movie.all
    @genres = Genre.all
  end

  def new
    @movie = Movie.new
    @genres = Genre.all
    @audiences = Movie.audience_types.keys
    @publishing_statuses = Movie.publishing_statuses.keys
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      @audiences = Movie.audience_types.keys
      @publishing_statuses = Movie.publishing_statuses.keys

      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @movie = Movie.find(params[:id])
    @genres = Genre.all
    @audiences = Movie.audience_types.keys
    @publishing_statuses = Movie.publishing_statuses.keys
  end

  def update
    @movie = Movie.find(params[:id])

    success = false

    ActiveRecord::Base.transaction do
      @movie.movies_genres.destroy_all
      success = @movie.update(movie_params)
    end

    if success
      redirect_to editor_movies_path
    else
      @genres = Genre.all
      @audiences = Movie.audience_types.keys
      @publishing_statuses = Movie.publishing_statuses.keys

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_genre
    @index = params[:index].to_i
  end

  def create_genre
    @movie = Movie.new(movies_genres: [ MoviesGenre.new ])
    @index = params[:index].to_i
  end

  private

  def movie_params
    params.require(:movie).permit(
      :title,
      :description,
      :released_on,
      :audience_type,
      :featured,
      :cover,
      :logo,
      :video,
      :publishing_status,
      movies_genres_attributes: [ :genre_id ]
    )
  end
end
