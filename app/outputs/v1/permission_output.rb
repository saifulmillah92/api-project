# frozen_string_literal: true

module V1
  class PermissionOutput < Outputs::Api
    def format
      {
        id: @object.id,
        object_id: @object.object_id,
        object_type: @object.object_type,
        key: @object.key,
        value: @object.value,
      }
    end
  end
end
