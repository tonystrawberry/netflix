# == Schema Information
#
# Table name: movies
#
#  id                                :bigint           not null, primary key
#  audience_type                     :integer          default("all"), not null
#  description                       :text             not null
#  featured                          :boolean          default(FALSE), not null
#  media_convert_progress_percentage :integer
#  media_convert_status              :integer          default("submitted"), not null
#  media_type                        :integer          default("movie"), not null
#  published_at                      :datetime
#  publishing_status                 :integer          default("draft"), not null
#  released_on                       :date             not null
#  title                             :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  media_convert_job_id              :string
#
require "test_helper"

class MovieTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
