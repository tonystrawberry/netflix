class MediaConvert::Base
  attr_reader :client

  def initialize
    client = Aws::MediaConvert::Client.new(
      region: "ap-northeast-1",
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
    )

    endpoints = client.describe_endpoints

    @client = Aws::MediaConvert::Client.new(
      region: "ap-northeast-1",
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key),
      endpoint: endpoints.endpoints[0].url
    )
  end
end
