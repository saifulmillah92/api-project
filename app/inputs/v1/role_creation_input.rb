# frozen_string_literal: true

module V1
  class RoleCreationInput < ::ApplicationInput
    strip_unknown_attributes

    required(:name)
    optional(:permissions).array as: PermissionCreationInput, deep: true

    output_keys(permissions: :permissions_attributes)
  end
end
