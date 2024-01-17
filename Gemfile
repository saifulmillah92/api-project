source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.5"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4"
gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# active record import allow us to import the record
gem "activerecord-import"

gem "active_storage_validations"

# after_commit
gem "after_commit_everywhere"

# google cloud storage
gem "google-cloud-storage"

# Sidekiq performance
gem "sidekiq", "~> 6.5"

# to generate authentication token
gem "knock"

# generate user
gem "devise"

# Rolify
gem "rolify"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis"

# request store
gem "request_store"

# for migrations
gem "strong_migrations"

# For throttling
gem "rack-attack", "6.4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "database_cleaner"
  gem "faker"
  gem "fuubar"
  gem "pry-doc"
  gem "pry-rails"
  gem "rb-readline"
  gem "rspec_junit_formatter"
  gem "rspec-rails"
  gem "rspec-sqlimit"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rspec"
end

group :test do
  gem "timecop"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
