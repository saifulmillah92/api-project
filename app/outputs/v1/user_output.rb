# frozen_string_literal: true

module V1
  class UserOutput < Outputs::Api
    def format
      {
        id: @object.id,
        username: @object.username,
        email: @object.email,
        state: @object.state,
        profile_picture: profile_picture,
        reset_password_token: @object.reset_password_token,
        reset_password_sent_at: @object.reset_password_sent_at,
      }
    end

    def full_format
      format.merge(address: address)
    end

    def login_format
      format.merge(authorization: authorization)
    end

    def auth_format
      format.merge(permissions: @object.current_permissions)
    end

    private

    def authorization
      @options[:authorization]
    end

    def address
      return unless @object.address

      AddressOutput.new(@object.address).format
    end

    def profile_picture
      return unless @object.profile_picture

      StoredFile.download_url(@object.profile_picture)
    end
  end
end
