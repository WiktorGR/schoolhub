# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Demo accounts, one per role. Safe to run many times: existing users are left as they are.
DEMO_PASSWORD = "demo12345"

{
  "admin@schoolhub.test" => :admin,
  "instruktor@schoolhub.test" => :instructor,
  "uczestnik@schoolhub.test" => :participant
}.each do |email_address, role|
  User.find_or_create_by!(email_address: email_address) do |user|
    user.role = role
    user.password = DEMO_PASSWORD
  end
end

puts "Demo accounts ready (password: #{DEMO_PASSWORD})."
