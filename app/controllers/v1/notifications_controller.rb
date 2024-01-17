# frozen_string_literal: true

module V1
  class NotificationsController < V1::ResourceController
    def index
      result = service.all(params)
      render_json_array result,
                        use: :notification_format,
                        current_user: current_user,
                        limit: @limit,
                        offset: @offset,
                        total: total_count
    end

    def see
      service.see(id: params[:id].to_i)
      render_ok
    end

    private

    def default_output
      version::ActivityOutput
    end

    def service
      NotificationService.new(current_user)
    end
  end
end
