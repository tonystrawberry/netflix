class MediaConvert::Base
  attr_reader :client

  def initialize
    client = Aws::MediaConvert::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    )

    endpoints = client.describe_endpoints

    @client = Aws::MediaConvert::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      endpoint: endpoints.endpoints[0].url
    )
  end
end
