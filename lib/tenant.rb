# frozen_string_literal: true

module Tenant
  class << self
    ACCESSOR_METHODS = [:default_tenant].freeze
    WRITER_METHODS = [:excluded_models].freeze

    attr_writer(*WRITER_METHODS)
    attr_accessor(*ACCESSOR_METHODS)

    def configure
      yield self if block_given?
    end

    def create_tenant!(schema)
      raise invalid("schema cannot be empty") if schema.blank?

      connection.execute("CREATE SCHEMA #{schema};")
      Migrator.migrate(schema)

      switch!(schema)
    end

    def switch!(schema)
      unless connection.schema_exists?(schema)
        raise invalid("Could not find schema #{schema}")
      end

      connection.execute("set search_path = #{schema}")
      connection.schema_search_path = schema
      Hotel.find_by(schema: schema)
    end

    def switch(schema)
      switch! schema
      yield
    ensure
      exit!
    end

    def current
      connection.schema_search_path.split(",").last.strip
    end

    def exit!
      connection.execute("set search_path = public")
    end

    def drop(schema)
      connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE;")
    end

    def excluded_models
      @excluded_models || []
    end

    def init!
      excluded_models.map(&:constantize).each do |model|
        model.table_name = "public.#{model.table_name}"
      end
    end

    def invalid(message)
      ActiveRecord::StatementInvalid.new(message)
    end

    def connection
      ActiveRecord::Base.connection
    end
  end
end
