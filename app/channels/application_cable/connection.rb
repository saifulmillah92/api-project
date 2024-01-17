# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      authenticate_connection
      self.current_user = Current.user
    end

    private

    def authenticate_connection
      auth_token = Knock::AuthToken.new(token: token)

      Current.user = auth_token.entity_for(User)
    rescue Knock.not_found_exception_class, JWT::DecodeError, JWT::EncodeError
      reject_unauthorized_connection
    end

    def token
      request.params[:token]
    end

    def report_error(resource)
      # not implemented yet
    end
  end
end
