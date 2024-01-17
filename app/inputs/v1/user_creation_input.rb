# frozen_string_literal: true

module V1
  class UserCreationInput < ::ApplicationInput
    strip_unknown_attributes

    required(:email)
    required(:username)
    required(:password)
    required(:state).any_of(User.states.values, default: "active")
    optional(:address).hash(allow_blank: true) do
      required(:street)
      optional(:city)
      optional(:state)
      optional(:postal_code).number
      optional(:country)
      required(:phone_number)
      optional(:additional_info)
    end

    output_keys(address: :address_attributes)

    validate :required_username

    def required_username
      errors.add(:username, :blank) if username.blank?
    end
  end
end
