# frozen_string_literal: true

module V1
  class PermissionUpdateInput < ::ApplicationInput
    strip_unknown_attributes

    optional(:id)
    required(:key)
    required(:value)

    BOOLEAN_SETTINGS = Permission::BOOLEAN_SETTINGS
    BOOLEAN_VALUES = Permission::BOOLEAN_VALUES

    def validate_key_value_pairs
      return unless key
      return if key.in?(BOOLEAN_SETTINGS) && value.in?(BOOLEAN_VALUES)

      raise ApplicationRecord::Invalid, "invalid value for key: #{key}"
    end
  end
end
