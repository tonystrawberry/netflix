require "aws-sdk-s3"

class CheckHlsVideosJob < ApplicationJob
  queue_as :default

  def perform
    # Get all movies with video attached and HLS video not attached
    Movie.with_attached_video.without_attached_hls_video.find_each do |movie|
      # Get the key of the attached video
      key = movie.video.key

      # Check the `bucket` specified in the `config/storage.yml` (amazon_s3_output_assets)
      # for the HLS video with the key of the attached video
      # and attach the HLS video to the movie

      s3_client = Aws::S3::Client.new(region: "ap-northeast-1", access_key_id: Rails.application.credentials.dig(:aws, :access_key_id), secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key))

      s3_object = nil
      begin
        s3_object = s3_client.head_object(bucket: "tonystrawberry-netflix-output-assets-development", key: "#{key}/HLS/#{key}.m3u8")
      rescue Aws::S3::Errors::NotFound
        # The HLS video is not found
        return
      end

      puts s3_object.inspect

      ActiveRecord::Base.transaction do
        blob = ActiveStorage::Blob.create!(
          key: "#{key}/HLS/#{key}.m3u8",
          filename: "#{key}.m3u8",
          content_type: "application/vnd.apple.mpegurl",
          service_name: "amazon_s3_output_assets",
          byte_size: s3_object.content_length,
          checksum: s3_object.etag.gsub(/"/, ""),
        )
        movie.hls_video.attach(blob)
      end
    end
  end
end
