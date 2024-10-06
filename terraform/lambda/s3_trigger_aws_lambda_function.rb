#!/usr/bin/env ruby

require 'aws-sdk-s3'
require 'aws-sdk-mediaconvert'
require 'json'
require 'securerandom'
require 'fileutils'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'

def lambda_handler(event:, context:)
  puts "Received event: #{JSON.generate(event)}"
  puts "Received context: #{JSON.generate(context)}"
  folder_name = event['Records'][0]['s3']['object']['key'].split('/')[0]
  source_s3_bucket = event['Records'][0]['s3']['bucket']['name']
  source_s3_key = event['Records'][0]['s3']['object']['key']
  source_s3 = "s3://#{source_s3_bucket}/#{source_s3_key}"
  source_s3_basename = File.basename(source_s3, '.*')
  destination_s3 = "s3://#{ENV['DestinationBucket']}"
  media_convert_role = ENV['MediaConvertRole']
  region = "ap-northeast-1"
  status_code = 200
  body = {}

  # Skip if the source is not a video file by checking file metadata `Content-Type`
  # Only get the object metadata to reduce the cost
  s3 = Aws::S3::Client.new(region: region)
  object = s3.head_object(bucket: source_s3_bucket, key: source_s3_key)
  content_type = object.content_type

  unless content_type == 'video/mp4'
    puts "Skipped non-video file: #{content_type}"
    status_code = 204
    body = { message: 'Skipped non-video file' }
    return
  end

  puts "Processing video file: #{source_s3}"

  # Use MediaConvert SDK UserMetadata to tag jobs with the assetID
  # Events from MediaConvert will have the assetID in UserMetadata
  job_metadata = { 'folderName' => folder_name }

  puts JSON.pretty_generate(event)

  begin
    # Job settings are in the lambda zip file in the current working directory
    job_settings = JSON.parse(File.read('job.json'))
    puts job_settings

    # Get the account-specific MediaConvert endpoint for this region
    mc_client = Aws::MediaConvert::Client.new(region: region)
    endpoints = mc_client.describe_endpoints

    # Add the account-specific endpoint to the client session
    client = Aws::MediaConvert::Client.new(region: region, endpoint: endpoints.endpoints[0].url)

    # Update the job settings with the source video from the S3 event and destination paths for converted videos
    job_settings['Inputs'][0]['FileInput'] = source_s3

    s3_key_hls = "#{folder_name}/HLS/#{source_s3_basename}"
    job_settings['OutputGroups'][0]['OutputGroupSettings']['HlsGroupSettings']['Destination'] = "#{destination_s3}/#{s3_key_hls}"

    s3_key_thumbnails = "#{folder_name}/Thumbnails/#{source_s3_basename}"
    job_settings['OutputGroups'][1]['OutputGroupSettings']['FileGroupSettings']['Destination'] = "#{destination_s3}/#{s3_key_thumbnails}"

    puts 'job_settings:'
    puts JSON.pretty_generate(job_settings)


    # Snake-casify the job settings keys
    # MediaConvert SDK requires snake-cased keys (recursive)
    job_settings = job_settings.deep_transform_keys { |key| key != "Audio Selector 1" ? key.underscore.to_sym : key }

    # Convert the video using AWS Elemental MediaConvert
    job = client.create_job(role: media_convert_role, user_metadata: job_metadata, settings: job_settings)
    puts JSON.pretty_generate(job)

  rescue StandardError => e
    puts "Exception: #{e.message}"
    status_code = 500
    raise
  ensure
    {
      statusCode: status_code,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*' }
    }
  end
end
