# frozen_string_literal: true

module V1
  class RoleOutput < Outputs::Api
    def format
      { id: @object.id, name: @object.name }
    end

    def full_format
      format.merge(permissions)
    end

    private

    def permissions
      return {} unless @object.permissions

      { permissions: PermissionOutput.array(@object.permissions).format }
    end
  end
end
