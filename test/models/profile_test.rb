# == Schema Information
#
# Table name: profiles
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  name       :string           not null
#  avatar     :string
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  language   :integer          default("en"), not null
#
require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
