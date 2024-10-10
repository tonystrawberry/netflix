class Secure::MoviesController < Secure::BaseController
  def index
    @genres = Genre.includes(:movies)

    @movies = @genres.each_with_object({}) do |genre, hash|
      hash[genre] = genre.movies
    end
  end

  def show
    @movie = Movie.find(params[:id])

    sign_cookie(@movie.hls_video.key)

    @cdn_url = "#{ENV["CLOUDFRONT_URL"]}/#{@movie.hls_video.key}"
  end

  private

  # Set the signed cookie for viewers to access the restricted video content
  def sign_cookie(s3_key)
    # Decore the private key (base64 encoded)
    signer = Aws::CloudFront::CookieSigner.new(
      key_pair_id: ENV["CLOUDFRONT_KEY_PAIR_ID"],
      private_key: Base64.decode64(ENV["CLOUDFRONT_PRIVATE_KEY"])
    )

    signer.signed_cookie(
      nil,
      policy: policy(s3_key, Time.zone.now + 1.minute)
    ).each do |key, value|
      cookies[key] = {
        value: value,
        domain: :all
      }
    end
  end

  # The policy for the signed cookie
  def policy(s3_key, expiry)
    {
      "Statement" => [
        {
          "Resource" => "#{ENV["CLOUDFRONT_URL"]}/#{s3_key}*",
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
