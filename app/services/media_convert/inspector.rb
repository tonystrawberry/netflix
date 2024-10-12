class MediaConvert::Inspector < MediaConvert::Base
  attr_reader :response, :status, :percentage

  def initialize
    super

    @response = nil
    @status = nil
    @percentage = nil
  end

  def inspect(job_id:)
    @response = client.get_job(id: job_id)
    @status = @response.job.status
    @percentage = @response.job.job_percent_complete

    {
      status: @status,
      percentage: @percentage
    }
  end
end
