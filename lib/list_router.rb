# frozen_string_literal: true

module ListRouter
  class << self
    VERSIONS = ["v1/"].freeze
    REGEX = Regexp.new(VERSIONS.join("|"))

    def call
      Rails.application.routes.routes.map do |route|
        controller, action = extract_controller_and_action(route)

        next unless valid_controller?(controller)

        normalized_controller = normalize_controller(controller)
        "#{normalized_controller}.#{action}" if action
      end.compact
    end

    def extract_controller_and_action(route)
      [route.defaults[:controller], route.defaults[:action]]
    end

    def valid_controller?(controller)
      controller.present? && REGEX.match?(controller)
    end

    def normalize_controller(controller)
      controller.gsub(REGEX, "").tr("/", ".")
    end
  end
end
