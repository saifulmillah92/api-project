# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Configs" do
  setup_users(["@nick", "@capt"])
  setup_roles!

  it "lists the configs" do
    get_json "/v1/settings/configs", {}, as_user(@nick)
    expect_response(
      :ok,
      data: {
        email: String,
        website: String,
        instagram_url: String,
      },
    )
  end
end
