# frozen_string_literal: true

require_relative "../migrator"

# namespace :db do
#   task migrate: :environment do
#     # get all current schemas
#     schemas = Hotel.pluck(:schema)
#     # List all the schemas you want to migrate here
#     schemas_to_migrate = schemas

#     # Loop through each schema and migrate pending migrations
#     schemas_to_migrate.each do |schema|
#       puts "schema name: #{schema}"
#       Migrator.migrate(schema)
#       puts "schema name: #{schema} Migrated"
#     end
#     puts "Migrations have been executed."
#   end

#   task rollback: :environment do
#     # get all current schemas
#     schemas = Hotel.pluck(:schema)

#     # steps to rollback
#     steps = ENV["STEP"].to_i

#     # List all the schemas you want to migrate here
#     schemas_to_migrate = schemas

#     # Loop through each schema and rollback migrations
#     schemas_to_migrate.each do |schema|
#       puts "schema name: #{schema}"
#       Migrator.rollback(schema, steps)
#       puts "schema name: #{schema} Reverted"
#     end
#     puts "Reverting have been executed."
#   end

#   namespace :migrate do
#     task up: :environment do
#       # get all current schemas
#       schemas = Hotel.pluck(:schema)

#       # version to up
#       version = ENV["VERSION"].to_i

#       # List all the schemas you want to up here
#       schemas_to_migrate = schemas

#       # Loop through each schema and rollback migrations
#       schemas_to_migrate.each do |schema|
#         puts "schema name: #{schema}"
#         Migrator.up(schema, version)
#       end
#       puts "Up have been executed."
#     end

#     task down: :environment do
#       # get all current schemas
#       schemas = Hotel.pluck(:schema)

#       # version to down
#       version = ENV["VERSION"].to_i

#       # List all the schemas you want to down here
#       schemas_to_migrate = schemas

#       # Loop through each schema and rollback migrations
#       schemas_to_migrate.each do |schema|
#         puts "schema name: #{schema}"
#         Migrator.down(schema, version)
#       end
#       puts "Down have been executed."
#     end
#   end
# end
