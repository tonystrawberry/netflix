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
class Profile < ApplicationRecord
  has_prefix_id :profile

  belongs_to :user

  has_one_attached :avatar, service: :amazon_s3_assets

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :language, presence: true

  enum :language, I18n.available_locales

  before_validation :generate_code, on: :create

  private

  # Generate a unique code for the profile.
  # @return [void]
  def generate_code
    self.code = SecureRandom.hex(8)
  end
end
