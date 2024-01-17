# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :object, polymorphic: true

  validates :key, presence: true, uniqueness: { scope: [:object_id, :object_type] }

  @defaults = {}

  BOOLEAN_VALUES = ["true", "false"].freeze

  MODULE_PERMISSION = [
    "modules.user_management",
    "modules.settings_management",
  ].freeze

  BOOLEAN_SETTINGS = ListRouter.call + MODULE_PERMISSION

  class << self
    attr_reader(:defaults)

    def key(name, default: nil)
      @defaults[name.to_s] = default
      define_singleton_method(name) do
        find_by(key: name) || new(key: name, value: default)
      end
    end

    def set!(key, value, object)
      where(
        object_type: object.class.name,
        object: object,
        key: key.to_s,
      ).first_or_initialize.update!(value: value.to_s)
    end
  end

  BOOLEAN_SETTINGS.each { |value| key(value, default: "false") }

  @defaults.each_value(&:freeze)
end
