class Secure::MoviesController < Secure::BaseController
  # GET /movies
  def index
    @genres = Genre.includes(:movies)

    @movies = @genres.each_with_object({}) do |genre, hash|
      hash[genre] = genre.movies.joins(:hls_video_attachment)
    end
  end

  # GET /movies/:id
  def show
    @movie = Movie.find(params[:id])

    sign_cookie(@movie.hls_video.key)

    @cdn_url = "#{ENV["CLOUDFRONT_URL"]}/#{@movie.hls_video.key}"
  end

  private

  # Set the signed cookie for viewers to access the restricted video content
  # This cookie will be used to subsequent requests to the CloudFront distribution
  # Reference: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CloudFront/CookieSigner.html
  def sign_cookie(s3_key)
    signer = Aws::CloudFront::CookieSigner.new(
      key_pair_id: ENV["CLOUDFRONT_KEY_PAIR_ID"],
      private_key: Base64.decode64(ENV["CLOUDFRONT_PRIVATE_KEY"])
    )

    signer.signed_cookie(
      nil,
      policy: policy(s3_key, Time.zone.now + 15.minute)
    ).each do |key, value|
      cookies[key] = {
        value: value,
        domain: :all
      }
    end
  end

  # The policy for the signed cookie that will be used to access the restricted video content
  # Reference: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-setting-signed-cookie-custom-policy.html
  def policy(s3_key, expiry)
    # The S3 key looks like this mm57enm1nx2u91ztntbu2idxxror/HLS/mm57enm1nx2u91ztntbu2idxxror.m3u8
    # But I would like the "Resource" to omit the file extension in order to match all files of the same media with different quality prefixes.
    # Example:
    # - mm57enm1nx2u91ztntbu2idxxror/HLS/mm57enm1nx2u91ztntbu2idxxror-270p.m3u8
    # - mm57enm1nx2u91ztntbu2idxxror/HLS/mm57enm1nx2u91ztntbu2idxxror-360p.m3u8
    resource_key = s3_key.split(".")[0]

    {
      "Statement" => [
        {
          "Resource" => "#{ENV["CLOUDFRONT_URL"]}/#{resource_key}*",
          "Condition" => {
            "DateLessThan" => {
              "AWS:EpochTime" => expiry.utc.to_i
            }
          }
        }
      ]
    }.to_json
  end
end
