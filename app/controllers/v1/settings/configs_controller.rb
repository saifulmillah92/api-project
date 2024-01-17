# frozen_string_literal: true

module V1
  module Settings
    class ConfigsController < ::V1::ResourceController
      def index
        result = service.all(params)
        render_json result
      end
    end
  end
end
