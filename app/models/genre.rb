# == Schema Information
#
# Table name: genres
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  key        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genres_on_code  (code) UNIQUE
#
class Genre < ApplicationRecord
  has_prefix_id :genre

  extend Mobility
  translates :name, type: :string

  has_many :movies_genres, dependent: :destroy
  has_many :movies, through: :movies_genres

  validates :code, presence: true, uniqueness: true

  before_validation :generate_code, on: :create

  private

  # Generate a unique code for the genre.
  # @return [void]
  def generate_code
    self.code = SecureRandom.hex(8)
  end
end
