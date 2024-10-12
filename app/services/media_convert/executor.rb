class MediaConvert::Executor < MediaConvert::Base
  attr_reader :response, :job_id

  def initialize
    super

    @response = nil
  end

  def execute(source_s3_key:)
    destination_s3_bucket_name = ENV["MEDIA_CONVERT_OUTPUT_BUCKET"]
    destination_video_s3_key = "#{source_s3_key}/HLS/video"
    destination_thumbnail_s3_key = "#{source_s3_key}/Thumbnails/thumbnail"

    settings = MediaConvert::Executor.job_settings(source_s3_key:, destination_s3_bucket_name:, destination_video_s3_key:, destination_thumbnail_s3_key:)

    @response = client.create_job(role: ENV["MEDIA_CONVERT_ROLE_ARN"], user_metadata: { "source_s3_key" => source_s3_key }, settings:)
    @job_id = @response.job.id

    {
      job_id: @job_id
    }
  end

  def self.job_settings(source_s3_key:, destination_s3_bucket_name:, destination_video_s3_key:, destination_thumbnail_s3_key:)
    {
      "timecode_config": {
        "source": "ZEROBASED"
      },
      "output_groups": [
        {
          "name": "Apple HLS",
          "outputs": [
            {
              "container_settings": {
                "container": "M3U8"
              },
              "video_description": {
                "width": 480,
                "height": 270,
                "codec_settings": {
                  "codec": "H_264",
                  "h264_settings": {
                    "max_bitrate": 1500000,
                    "rate_control_mode": "QVBR",
                    "scene_change_detect": "TRANSITION_DETECTION"
                  }
                }
              },
              "audio_descriptions": [
                {
                  "audio_source_name": "Audio Selector 1",
                  "codec_settings": {
                    "codec": "AAC",
                    "aac_settings": {
                      "bitrate": 96000,
                      "coding_mode": "CODING_MODE_2_0",
                      "sample_rate": 48000
                    }
                  }
                }
              ],
              "output_settings": {
                "hls_settings": {}
              },
              "name_modifier": "-480x270"
            },
            {
              "container_settings": {
                "container": "M3U8"
              },
              "video_description": {
                "width": 640,
                "height": 360,
                "codec_settings": {
                  "codec": "H_264",
                  "h264_settings": {
                    "max_bitrate": 2000000,
                    "rate_control_mode": "QVBR",
                    "scene_change_detect": "TRANSITION_DETECTION"
                  }
                }
              },
              "audio_descriptions": [
                {
                  "codec_settings": {
                    "codec": "AAC",
                    "aac_settings": {
                      "bitrate": 96000,
                      "coding_mode": "CODING_MODE_2_0",
                      "sample_rate": 48000
                    }
                  }
                }
              ],
              "output_settings": {
                "hls_settings": {}
              },
              "name_modifier": "-640x360"
            },
            {
              "container_settings": {
                "container": "M3U8"
              },
              "video_description": {
                "width": 1280,
                "height": 720,
                "codec_settings": {
                  "codec": "H_264",
                  "h264_settings": {
                    "max_bitrate": 4000000,
                    "rate_control_mode": "QVBR",
                    "scene_change_detect": "TRANSITION_DETECTION"
                  }
                }
              },
              "audio_descriptions": [
                {
                  "codec_settings": {
                    "codec": "AAC",
                    "aac_settings": {
                      "bitrate": 96000,
                      "coding_mode": "CODING_MODE_2_0",
                      "sample_rate": 48000
                    }
                  }
                }
              ],
              "output_settings": {
                "hls_settings": {}
              },
              "name_modifier": "-1280x720"
            },
            {
              "container_settings": {
                "container": "M3U8"
              },
              "video_description": {
                "width": 1920,
                "height": 1080,
                "codec_settings": {
                  "codec": "H_264",
                  "h264_settings": {
                    "max_bitrate": 8000000,
                    "rate_control_mode": "QVBR",
                    "scene_change_detect": "TRANSITION_DETECTION"
                  }
                }
              },
              "audio_descriptions": [
                {
                  "codec_settings": {
                    "codec": "AAC",
                    "aac_settings": {
                      "bitrate": 96000,
                      "coding_mode": "CODING_MODE_2_0",
                      "sample_rate": 48000
                    }
                  }
                }
              ],
              "output_settings": {
                "hls_settings": {}
              },
              "name_modifier": "-1920x1080"
            }
          ],
          "output_group_settings": {
            "type": "HLS_GROUP_SETTINGS",
            "hls_group_settings": {
              "segment_length": 10,
              "caption_language_setting": "OMIT",
              "destination": "s3://#{destination_s3_bucket_name}/#{destination_video_s3_key}",
              "min_segment_length": 0
            }
          }
        },
        {
          "name": "File Group",
          "outputs": [
            {
              "container_settings": {
                "container": "RAW"
              },
              "video_description": {
                "codec_settings": {
                  "codec": "FRAME_CAPTURE",
                  "frame_capture_settings": {
                    "framerate_numerator": 1,
                    "framerate_denominator": 3,
                    "max_captures": 100
                  }
                }
              }
            }
          ],
          "output_group_settings": {
            "type": "FILE_GROUP_SETTINGS",
            "file_group_settings": {
              "destination": "s3://#{destination_s3_bucket_name}/#{destination_thumbnail_s3_key}"
            }
          }
        }
      ],
      "follow_source": 1,
      "inputs": [
        {
          "audio_selectors": {
            "Audio Selector 1": {
              "default_selection": "DEFAULT"
            }
          },
          "video_selector": {},
          "timecode_source": "ZEROBASED",
          "file_input": "s3://#{source_s3_key}"
        }
      ]
    }
  end
end
