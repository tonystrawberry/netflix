# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

require 'active_record/fixtures'

# For each file in the fixtures directory, load the fixtures into the database.

fixtures_dir = Rails.root.join('test', 'fixtures')

# Order is important here, as some fixtures may depend on others.
# For example, a profile fixture may depend on a user fixture.
# Therefore, we need to load the user fixtures first.

[
  'administrators',
  'users',
  'profiles',
  'genres',
  'mobility_string_translations',
  'movies'
].each do |fixture|
  "Loading #{fixture} fixtures..."
  ActiveRecord::FixtureSet.create_fixtures(fixtures_dir, fixture)
end
