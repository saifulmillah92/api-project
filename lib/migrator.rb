# frozen_string_literal: true

module Migrator
  class << self
    def migrate(schema)
      conn.schema_search_path = schema
      migration_context.new(migrations_paths, schema_migration).migrate
    end

    def rollback(schema, steps)
      conn.schema_search_path = schema
      migration_context.new(migrations_paths, schema_migration).rollback(steps)
    end

    def up(schema, version)
      conn.schema_search_path = schema
      conn.migration_context.run(:up, version)
    end

    def down(schema, version)
      conn.schema_search_path = schema
      conn.migration_context.run(:down, version)
    end

    def migration_context
      ActiveRecord::MigrationContext
    end

    def migrations_paths
      ActiveRecord::Migrator.migrations_paths
    end

    def schema_migration
      ActiveRecord::SchemaMigration
    end

    def conn
      ActiveRecord::Base.connection
    end
  end
end
