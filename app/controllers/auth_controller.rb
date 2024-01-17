# frozen_string_literal: true

class AuthController < ApplicationController
  before_action :authenticate_user, only: :index

  def index
    render_json current_user, V1::UserOutput, use: :auth_format
  end

  def login
    result = service.login(**auth_params)
    render_json result[:user],
                V1::UserOutput,
                authorization: result[:authorization],
                status: :created,
                message: t("ok"),
                use: :login_format
  end

  def forgot_password
    result = service.forgot_password(**auth_params)
    render_json result, V1::UserOutput
  end

  def reset_password
    service.reset_password(**auth_params)
    render_ok
  end

  private

  def service
    AuthService.new(nil)
  end

  def auth_params
    params.slice :email, :password, :reset_password_token
  end
end
