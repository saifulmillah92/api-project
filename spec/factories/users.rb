# frozen_string_literal: true

module Factories
  def create_user(email = random_email, **params)
    User.create!(email: email, username: email, password: "password", **params)
  end

  def random_email
    SecureRandom.alphanumeric(10) << "@" << SecureRandom.alphanumeric(10) << ".com"
  end
end
