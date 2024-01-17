# frozen_string_literal: true

# Configs
class Config < ApplicationRecord
  @defaults = {}

  def self.key(name, default: nil)
    @defaults[name.to_sym] = default
    define_singleton_method(name) do
      result = find_by(key: name) || new(key: name, value: default)
      result.value = result._value(default)
      result
    end
  end

  def self.to_h
    result_hash = @defaults.dup
    where(key: @defaults.keys).find_each do |c|
      key = c.key.to_sym
      default_value = result_hash[key]
      result_hash[key] = c._value(default_value)
    end
    result_hash
  end

  def self.keys
    @defaults.keys
  end

  def _value(default)
    return value unless default.is_a?(Hash) && default.present?

    value.slice(*default.keys).compact.reverse_merge(default)
  end

  ###############################################################################
  ## Configuration Documentation
  ###############################################################################
  key :email, default: "info@yourdomain.com"
  key :website, default: "www.yourdomain.com"
  key :instagram_url, default: ""
  key :youtube_url, default: ""
  key :facebook_url, default: ""
  key :address1, default: ""
  key :address2, default: ""
  key :phone, default: ""

  key :use_cache, default: false

  @defaults.each_value(&:freeze)

  def set!(value)
    update!(value: value)
  end

  def merge!(new_value)
    set! value.merge(new_value)
  end
end
