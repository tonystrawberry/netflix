class Editor::GenresController < Editor::BaseController
  def index
    @genres = Genre.all
  end

  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)

    if @genre.save
      redirect_to editor_genres_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @genre = Genre.find(params[:id])
  end

  def update
    @genre = Genre.find(params[:id])

    if @genre.update(genre_params)
      redirect_to editor_genres_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def genre_params
    params.require(:genre).permit(:key, :name_en, :name_ja)
  end
end
