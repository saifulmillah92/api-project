# frozen_string_literal: true

module V1
  class ActivityOutput < Outputs::Api
    def format
      options = @options[:presenter].to_h
      ::V1::ActivityPresenter.new(@object, **options).as_json
    end

    def notification_format
      options[:use] = :contextual_presentation
      ::V1::NotificationPresenter.new(@object, **options).as_json
    end
  end
end
