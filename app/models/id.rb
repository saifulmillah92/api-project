# frozen_string_literal: true

module Id
  def self.[](value)
    return value.map { |each| self[each] } if value.is_a?(Array)
    return value if value.respond_to?(:id)
    return value.to_i if value.is_a?(String)

    value
  end
end
