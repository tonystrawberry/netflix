class Profile < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  before_validation :generate_code, on: :create

  private

  # Generate a unique code for the profile.
  # @return [void]
  def generate_code
    self.code = SecureRandom.hex(8)
  end
end
