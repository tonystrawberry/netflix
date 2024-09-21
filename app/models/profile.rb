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
class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :language, presence: true

  enum :language, I18n.available_locales

  before_validation :generate_code, on: :create

  private

  # Generate a unique code for the profile.
  # @return [void]
  def generate_code
    binding.irb

    self.code = SecureRandom.hex(8)
  end
end
