# frozen_string_literal: true

module Factories
  def access_token(user, **params)
    @_tokens ||= {}
    @_tokens[[user, params]] ||= create_access_token(user, **params).token
  end

  def admin_token(user, **params)
    @_admin_tokens ||= {}
    @_admin_tokens[[user, params]] ||= create_admin_token(user, **params).token
  end

  def create_access_token(user, **params)
    ::Knock::AuthToken.new payload: { sub: user.id, **params }
  end

  def create_admin_token(user, **params)
    create_access_token(user, **params)
  end
end
