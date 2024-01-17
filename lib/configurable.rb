# frozen_string_literal: true

# Rely on a class to have #config method
module Configurable
  def configurable(name, default: nil, &coercion)
    name = name.to_s
    getter = name
    setter = "#{name}="
    coercion ||= proc { |v| v }

    define_method(getter) { config[name] }
    define_method(setter) { |value| config[name] = coercion.call(value) }

    return if default.nil?

    after_initialize do
      next unless has_attribute?(:config)
      next unless __send__(getter).nil?

      __send__(setter, default)
    end
  end
end
