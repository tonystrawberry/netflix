# == Schema Information
#
# Table name: movies
#
#  id                                :bigint           not null, primary key
#  audience_type                     :integer          default("all"), not null
#  description                       :text             not null
#  featured                          :boolean          default(FALSE), not null
#  media_convert_progress_percentage :integer
#  media_convert_status              :integer          default("submitted"), not null
#  media_type                        :integer          default("movie"), not null
#  published_at                      :datetime
#  publishing_status                 :integer          default("draft"), not null
#  released_on                       :date             not null
#  title                             :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  media_convert_job_id              :string
#
class Movie < ApplicationRecord
  has_prefix_id :movie

  broadcasts_to ->(movie) { [ "movies" ] }, inserts_by: :prepend, partial: "editor/movies/movie"

  has_one_attached :cover
  has_one_attached :logo
  has_one_attached :video
  has_one_attached :hls_video, service: :amazon_s3_output_assets

  enum publishing_status: { draft: 0, published: 1 }, _prefix: true
  enum audience_type: { all: 0, kids_7: 1, kids_12: 2, teens_13: 3, adults_16: 4, adults_18: 5 }, _prefix: true
  enum media_type: { movie: 0, series: 1 }, _prefix: true
  enum media_convert_status: { submitted: 0, progressing: 1, complete: 2, canceled: 3, error: 4, internal_error: 5 }, _prefix: true

  has_many :movies_genres, dependent: :destroy
  has_many :genres, through: :movies_genres

  accepts_nested_attributes_for :movies_genres

  validates :title, presence: true
  validates :description, presence: true
  validates :released_on, presence: true
  validates :publishing_status, presence: true
  validates :audience_type, presence: true
  validates :media_type, presence: true
  validates :featured, inclusion: { in: [ true, false ] }

  scope :published, -> { where(publishing_status: :published) }

  before_save :set_published_at, if: -> { publishing_status_published? && saved_change_to_publishing_status? }

  private

  # Set the published date when the movie is published.
  # @return [void]
  def set_published_at
    self.published_at = Time.zone.now
  end
end
