# frozen_string_literal: true

module V1
  class UsersController < V1::ResourceController
    before_action :authenticate_permission!, except: [:show, :update]

    private

    def service
      AppService.new(current_user, model_class, ::Users.new)
    end

    def authenticate_permission!
      authorize! can?("modules.user_management")
    end
  end
end
