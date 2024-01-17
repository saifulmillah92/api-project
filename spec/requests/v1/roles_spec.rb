# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Roles" do
  setup_users(["@nick", "@capt"])
  setup_roles!

  describe "Index" do
    it "returns ok" do
      get_json "/v1/roles", {}, as_user(@nick)
      expect_response(:ok)
    end

    it "returns oke with filter" do
      get_json "/v1/roles", { q: "user" }, as_user(@nick)
      expect_response(:ok)
      expect(response_body[:data].size).to eq(1)
    end

    it "doesn't do N+1 query" do
      expect do
        get_json "/v1/roles", {}, as_user(@nick)
      end.not_to exceed_query_limit(6)
    end

    context "with permissions" do
      it "returns ok when user has permission" do
        Permission.set!("roles.index", "true", @capt.role)
        Permission.set!("modules.user_management", "true", @capt.role)
        get_json "/v1/roles", {}, as_user(@capt)
        expect_response(:ok)
      end

      it "returns ok when user has two roles and overriden the false value" do
        get_json "/v1/roles", {}, as_user(@capt)
        expect_response(:forbidden)

        @capt.add_role :admin
        get_json "/v1/roles", {}, as_user(@capt)
        expect_response(:ok)
      end

      it "returns forbidden when user has no permission" do
        get_json "/v1/roles", {}, as_user(@capt)
        expect_response(:forbidden)
      end
    end
  end
end
