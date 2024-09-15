# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  { name_en: "Anime", name_ja: "アニメ", key: "anime" },
  { name_en: "Comedy", name_ja: "コメディ", key: "comedy" },
  { name_en: "Drama", name_ja: "ドラマ", key: "drama" },
  { name_en: "Fantasy", name_ja: "ファンタジー", key: "fantasy" },
  { name_en: "Horror", name_ja: "ホラー", key: "horror" },
  { name_en: "Mystery", name_ja: "ミステリー", key: "mystery" },
  { name_en: "Romance", name_ja: "ロマンス", key: "romance" },
  { name_en: "Sci-Fi", name_ja: "SF", key: "sci-fi" },
  { name_en: "Thriller", name_ja: "スリラー", key: "thriller" }
].each do |attrbutes|
  genre = Genre.find_or_initialize_by(key: attrbutes[:key])

  next if genre.persisted?

  genre.name = attrbutes[:name_en]
  genre.name_ja = attrbutes[:name_ja]
  genre.save
end
