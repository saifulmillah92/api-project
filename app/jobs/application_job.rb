# frozen_string_literal: true

require "sidekiq/api"

class ApplicationJob
  include RedisProgressCounter
  include Sidekiq::Worker

  private_class_method :queue_as

  def self.queue_as(name, **options)
    sidekiq_options queue: name, **options
  end

  def broadcast_to(user, type, object, **options)
    BackgroundJobProgressChannel.broadcast_to(
      [user], type: type, object: object, **options,
    )
  end

  def error_message(error)
    Outputs::Exception.new(error, debug: !Rails.env.production?).root_json
  end
end
