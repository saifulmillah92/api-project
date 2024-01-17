# frozen_string_literal: true

module V1
  class UserUpdateInput < ::ApplicationInput
    strip_unknown_attributes

    optional(:email)
    optional(:username)
    optional(:password)
    optional(:state).any_of(User.states.values, default: "active")
    optional(:address).hash(allow_blank: true) do
      optional(:id)
      required(:street)
      optional(:city)
      optional(:state)
      optional(:postal_code).number
      optional(:country)
      required(:phone_number)
      optional(:additional_info)
    end

    output_keys(address: :address_attributes)
  end
end
