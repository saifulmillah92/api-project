# frozen_string_literal: true

module V1
  class RolesController < V1::ResourceController
    before_action :authenticate_permission!

    private

    def service
      AppService.new(current_user, model_class, ::Roles.new)
    end

    def authenticate_permission!
      authorize! can?("modules.user_management")
    end
  end
end
