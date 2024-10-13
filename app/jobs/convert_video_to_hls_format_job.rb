require "aws-sdk-s3"

class ConvertVideoToHlsFormatJob < ApplicationJob
  queue_as :default

  def perform(movie_id:)
    movie = Movie.find(movie_id)

    media_convert_job_id = MediaConvert::Executor.new.execute(source_s3_key: "#{Rails.application.config.active_storage.service_configurations["amazon_s3_assets"]["bucket"]}/#{movie.video.key}")[:job_id]

    movie.update!(media_convert_job_id:, media_convert_status: :submitted)

    CheckHlsVideosJob.set(wait: 15.seconds).perform_later(movie_id:)
  end
end
