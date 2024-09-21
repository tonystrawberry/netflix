# == Schema Information
#
# Table name: profiles
#
#  id         :bigint           not null, primary key
#  avatar     :string
#  code       :string           not null
#  language   :integer          default("en"), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_profiles_on_code     (code) UNIQUE
#  index_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
