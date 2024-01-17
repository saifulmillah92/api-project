# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Notifications" do
  setup_users(["@nick", "@capt"])

  def create_activity(event, user, object)
    Activity.create(event: event, user: user, object: object, context: object)
  end

  describe "Index and See" do
    before do
      @user = create_user(first_name: "Luffy")
      @capt.update! first_name: "Capt"
      @nick.update! first_name: "Nick"

      activity = create_activity("users.create", @capt, @user)
      activity.audiences.create(context: "target", observer_id: @nick.id)
    end

    it "returns ok" do
      get_json "/v1/notifications", { page: 1 }, as_user(@nick)
      message = "Hello **%1s**, this user created by: **%2s**"
      formatted_message = format(message, @nick.first_name, @capt.first_name)
      expect_response(
        :ok,
        data: [
          {
            id: Integer,
            notification_type: "user",
            text: {
              title: "New User: #{@user.first_name}", message: formatted_message,
            },
          },
        ],
      )
    end

    it "sees the correctly" do
      get_json "/v1/notifications", { page: 1 }, as_user(@nick)
      expect_response(
        :ok, data: [{ id: Integer, notification_type: "user", seen: false }],
      )
      id = response_body[:data][0][:id]
      put_json "/v1/notifications/#{id}", {}, as_user(@nick)
      expect_response(:ok)

      get_json "/v1/notifications", { page: 1 }, as_user(@nick)
      expect_response(
        :ok, data: [{ id: Integer, notification_type: "user", seen: true }],
      )
    end
  end
end
