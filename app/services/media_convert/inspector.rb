class MediaConvert::Inspector < MediaConvert::Base
  attr_reader :response, :status, :percentage

  def initialize
    super

    @response = nil
    @status = nil
    @percentage = nil
    @output_s3_key = nil
  end

  def inspect(job_id:)
    @response = client.get_job(id: job_id)

    puts @response.to_json


    @status = @response.job.status
    @percentage = @response.job.job_percent_complete
    @output_s3_key = @response.job.settings.output_groups[0].output_group_settings.hls_group_settings.destination

    if @output_s3_key.present?
      @output_s3_key = "#{@output_s3_key.gsub("s3://#{ENV['MEDIA_CONVERT_OUTPUT_BUCKET']}/", "")}.m3u8"
    end

    {
      status: @status,
      percentage: @percentage,
      output_s3_key: @output_s3_key
    }
  end
end
