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
require "test_helper"

class GenreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
