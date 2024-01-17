# frozen_string_literal: true

module V1
  class AddressOutput < Outputs::Api
    def format
      {
        id: @object.id,
        street: @object.street,
        phone_number: @object.phone_number,
        city: @object.city,
        postal_code: @object.postal_code,
        state: @object.state,
        country: @object.country,
        additional_info: @object.additional_info,
      }
    end
  end
end
