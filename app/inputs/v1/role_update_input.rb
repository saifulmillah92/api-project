# frozen_string_literal: true

module V1
  class RoleUpdateInput < ::ApplicationInput
    strip_unknown_attributes

    required(:name)
    optional(:permissions).array as: V1::PermissionUpdateInput, deep: true

    output_keys(permissions: :permissions_attributes)
  end
end
