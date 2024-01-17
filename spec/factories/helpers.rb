# frozen_string_literal: true

module Factories
  def current_time
    DateTime.now
  end

  def secure_random_hex
    SecureRandom.hex(30)
  end
end
