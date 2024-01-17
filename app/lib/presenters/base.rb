# frozen_string_literal: true

module Presenters
  # Railsystem::Presenters::Base
  class Base < Presenters::Basic
    def self.new(response, **options)
      return super unless response.is_a?(Response::Object)

      case response.type
      when :success then super(response.data, status(options, 200))
      when :created then super(response.data, status(options, 201))
      else failure(response, **options.except(:status))
      end
    end

    def self.failure(response, **options)
      case response.type
      when :unauthenticated then error_presenter(response.error, status(options, 401))
      when :not_allowed then error_presenter(response.error, status(options, 403))
      when :not_found then error_presenter(response.error, status(options, 404))
      when :invalid then error_presenter(response.error, status(options, 422))
      else error_presenter(response.error, status(options, 400))
      end
    end

    def self.status(options, default)
      { status: default }.merge!(options)
    end

    def self.array(objects, **options)
      if objects.respond_to?(:success?) && !objects.success?
        failure(objects, **options.except(:status))
      else
        Presenters::Array.new(objects, **options, presenter: self)
      end
    end

    def self.error_presenter(*args)
      Presenters::Error.new(*args)
    end
  end
end
