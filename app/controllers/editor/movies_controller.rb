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

  def new_genre
    movie_id = params[:movie_id]

    @movie = if movie_id.present?
              Movie.find(movie_id)
            else
              Movie.new
            end

    @movies_genre = @movie.movies_genres.new
  end

  def destroy_genre
    @id = params[:id]
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
      :publishing_status,
      movies_genres_attributes: [:genre_id]
    )
  end
end
