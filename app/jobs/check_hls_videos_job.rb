require "aws-sdk-s3"

class CheckHlsVideosJob < ApplicationJob
  queue_as :default

  rescue_from StandardError do |exception|
    Rails.logger.error(exception)

    @movie.update!(media_convert_status: :internal_error)
  end

  def perform(movie_id:)
    @movie = Movie.find(movie_id)

    inspect_result = MediaConvert::Inspector.new.inspect(job_id: @movie.media_convert_job_id)

    @movie.update!(media_convert_status: inspect_result[:status].downcase.to_sym, media_convert_progress_percentage: inspect_result[:percentage])


    case inspect_result[:status]
    when "SUBMITTED", "PROGRESSING"
      CheckHlsVideosJob.set(wait: 15.seconds).perform_later(movie_id: @movie.id)
    when "COMPLETE"
      attach_hls_video(movie: @movie, output_s3_key: inspect_result[:output_s3_key])
    when "CANCELED", "ERROR"
    end
  end

  private

  def attach_hls_video(movie:, output_s3_key:)
    # Check the `bucket` specified in the `config/storage.yml` (amazon_s3_output_assets)
    # for the HLS video with the key of the attached video
    # and attach the HLS video to the movie
    s3_client = Aws::S3::Client.new(region: "ap-northeast-1", access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])

    s3_object = s3_client.head_object(bucket: "tonystrawberry-netflix-output-assets-development", key: output_s3_key)

    ActiveRecord::Base.transaction do
      blob = ActiveStorage::Blob.create!(
        key: output_s3_key,
        filename: output_s3_key.split("/").last,
        content_type: "application/vnd.apple.mpegurl",
        service_name: "amazon_s3_output_assets",
        byte_size: s3_object.content_length,
        checksum: s3_object.etag.gsub(/"/, ""),
      )
      movie.hls_video.attach(blob)
    end
  end
end
