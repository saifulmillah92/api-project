# frozen_string_literal: true

Dir[Rails.root.join("spec/factories/**/*.rb")].sort.each do |file|
  require file
end

module Factories
  def create_user(email = random_email, **params)
    user = User.find_or_initialize_by(email: email, username: email)
    user.update!(password: "password", **params)
    user
  end

  def create_role(name, *permissions)
    role = Role.find_or_initialize_by(name: name)
    role.update!(permissions_attributes: permissions)
    role
  rescue StandardError => _e
    nil
  end

  def random_email
    SecureRandom.alphanumeric(10) << "@" << SecureRandom.alphanumeric(10) << ".com"
  end

  module ClassMethods
    USERS = {
      "@nick" => ["superadmin@yourdomain.com", nil, { state: "active" }],
      "@capt" => ["capt@yourdomain.com", :user, { state: "active" }],
    }.freeze

    ROLES = {
      "admin" => Permission.defaults.map { |key, _| { key: key, value: "true" } },
      "user" => [],
    }.freeze

    def setup_users(keys)
      before(:all) do
        keys.each do |key|
          email, role, params = USERS.fetch(key)
          user = create_user(email, **params)
          user.add_role role if role
          instance_variable_set(key, user)
        end
      end
    end

    def setup_roles!
      before(:all) do
        # ROLES.each { |key, values| create_role(key, *values) }
        ROLES.each { |key, values| create_role(key, *values) }
      end
    end
  end
end

RSpec.configure do |config|
  config.include Factories
  config.extend Factories::ClassMethods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }
end
