# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Auth" do
  setup_users(["@nick"])

  def try_request(url, params, from_ip: nil)
    if from_ip
      allow_any_instance_of(Rack::Request).to receive(:ip).and_return(from_ip)
    end

    post_json url, params
  end

  def many_times
    30.times { return if yield == 429 }
  end

  before do
    ENV["DISABLE_THROTTLE"] = nil
  end

  after do
    ENV["DISABLE_THROTTLE"] = "1"
    Rails.cache.clear
  end

  describe "Auth" do
    it "returns ok" do
      get_json "/auth", {}, as_user(@nick)
      expect_response(:ok, data: { id: Integer, email: @nick.email })
    end

    it "includes permissions" do
      get_json "/auth", {}, as_user(@nick)
      expect_response(
        :ok,
        data: {
          id: Integer,
          email: @nick.email,
          permissions: {
            "modules.user_management": "true",
            "roles.create": "true",
            "roles.destroy": "true",
          },
        },
      )
    end

    it "returns unauthenticated when token is expired" do
      token = create_access_token(@nick).token
      Timecop.freeze(2.days.from_now.to_date) do
        get_json "/auth", {}, { Authorization: "Bearer #{token}" }
        expect_error_response(401, "Unauthorized")
      end
    end

    it "returns unauthenticated" do
      get_json "/auth", {}
      expect_error_response(401, "Unauthorized")
    end
  end

  describe "Login" do
    let(:login_url) { "/auth/sign-in" }
    let(:params) { { email: @nick.email, password: "password" } }

    it "returns ok" do
      post_json login_url, params
      expect_response(
        201,
        {
          message: "OK",
          data: { id: Integer, authorization: { token: String } },
        },
      )
    end

    it "returns error when email is not exist" do
      params[:email] = "a@.co"
      post_json login_url, params
      expect_error_response(422, "User not registered")
    end

    it "returns error when password is invalid" do
      params[:password] = "11111"
      post_json login_url, params
      expect_error_response(422, "Invalid email or password")
    end

    context "with throttle" do
      it "allows requests within limit" do
        3.times { |x| try_request(login_url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:created)
      end

      it "throttles too many requests from different ips" do
        many_times { |x| try_request(login_url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:too_many_requests)
        expect(response_body).to be_json_type(
          errors: {
            code: 429,
            message: String,
          },
        )
      end
    end
  end

  describe "Forgot Password" do
    let(:url) { "/auth/forgot-password" }
    let(:params) { { email: @nick.email } }

    it "returns ok" do
      post_json url, params
      expect_response(
        200,
        {
          message: "OK",
          data: { id: Integer, reset_password_token: String },
        },
      )
    end

    it "returns error when email is not exist" do
      params[:email] = "a@.co"
      post_json url, params

      expect_error_response(422, "User not registered")
    end

    context "with throttle" do
      it "allows requests within limit" do
        3.times { |x| try_request(url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:ok)
      end

      it "throttles too many requests from different ips" do
        many_times { |x| try_request(url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:too_many_requests)
        expect(response_body).to be_json_type(
          errors: {
            code: 429,
            message: String,
          },
        )
      end
    end
  end

  describe "Reset Password" do
    let(:url) { "/auth/reset-password" }
    let(:params) { { email: @nick.email } }

    it "returns ok" do
      post_json "/auth/forgot-password", params
      expect_response(:ok)

      params[:reset_password_token] = response_body[:data][:reset_password_token]
      params[:password] = "111111"
      post_json url, params
      expect_response(200, { message: "OK" })
    end

    it "returns error when reset password toke is invalid" do
      params[:reset_password_token] = "hfdkfhkd"
      params[:password] = "111111"
      post_json url, params

      expect_error_response(422, "Invalid Token or Email")
    end

    context "with throttle" do
      before do
        post_json "/auth/forgot-password", params
        expect_response(:ok)

        params[:reset_password_token] = response_body[:data][:reset_password_token]
        params[:password] = "111111"
      end

      it "allows requests within limit" do
        2.times { |x| try_request(url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "throttles too many requests from different ips" do
        many_times { |x| try_request(url, params, from_ip: [x, x, x, x].join(".") ) }

        expect(response).to have_http_status(:too_many_requests)
        expect(response_body).to be_json_type(
          errors: {
            code: 429,
            message: String,
          },
        )
      end
    end
  end
end
