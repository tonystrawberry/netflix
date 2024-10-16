# == Schema Information
#
# Table name: movies_genres
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  genre_id   :bigint           not null
#  movie_id   :bigint           not null
#
# Indexes
#
#  index_movies_genres_on_genre_id  (genre_id)
#  index_movies_genres_on_movie_id  (movie_id)
#
# Foreign Keys
#
#  fk_rails_...  (genre_id => genres.id)
#  fk_rails_...  (movie_id => movies.id)
#
class MoviesGenre < ApplicationRecord
  belongs_to :movie
  belongs_to :genre
end
