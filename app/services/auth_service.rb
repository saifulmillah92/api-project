# frozen_string_literal: true

class AuthService < AppService
  def initialize(user = nil)
    super(user, User)
  end

  def login(**params)
    user = find_by(params.except(:password).to_h.symbolize_keys)
    assert! user, on_error: t("auth.not_registered")

    valid_password = user.authenticate(params[:password])
    assert! valid_password, on_error: t("auth.invalid_password")

    { user: user, authorization: authorization_token(user) }
  end

  def forgot_password(**params)
    user = find_by(email: params[:email])
    assert! user, on_error: t("auth.not_registered")

    user.update(
      reset_password_token: secure_random_hex,
      reset_password_sent_at: Current.time,
    )
    user
  end

  def reset_password(**params)
    user = find_by(
      email: params[:email], reset_password_token: params[:reset_password_token],
    )
    assert! user, on_error: t("auth.invalid_token_or_email")
    assert! params[:password].present?, on_error: t("blank", r: "Password")

    user.update!(password: params[:password], reset_password_token: nil)
    user
  end

  private

  def authorization_token(user)
    ::Knock::AuthToken.new payload: { sub: user.id }
  end
end
