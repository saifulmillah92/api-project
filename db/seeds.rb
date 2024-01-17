# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

def create_role(name, *permissions)
  role = Role.find_or_initialize_by(name: name)
  role.update!(permissions_attributes: permissions)
  role
rescue StandardError => _e
  nil
end

# Set Default Roles And Users
ROLES = {
  "admin" => Permission.defaults.map { |key, _| { key: key, value: "true" } },
  "user" => [],
}.freeze

ROLES.each { |key, values| create_role(key, *values) }

User::SUPERADMINS.each do |admin|
  params = { email: admin, username: admin, password: "password" }
  input = V1::UserCreationInput.new(params)
  user = User.find_or_initialize_by(email: admin)
  user.update!(input.output)
end

# 100.times do
#   params = Faker::Internet.user("username", "email").merge(password: "password")
#   input = V1::UserCreationInput.new(params)
#   user = User.find_or_initialize_by(email: input.output[:email])
#   user.update!(input.output)
#   user.add_role :user
# end
