# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Uploads" do
  setup_users(["@nick", "@capt"])

  describe "Presign for uploading" do
    doc_api :get, "/v1/uploads/presign"

    it "returns ok", doc: true do
      params = { directory: "pictures", extension: "jpg" }
      get_json "/v1/uploads/presign", params, as_user(@capt)
      expect_response(
        :ok,
        data: {
          path: String,
          upload_url: match(/\Ahttp.*jpg\?X-Goog-Algorithm=.*\z/),
        },
      )
    end

    it "returns ok for files jpeg", doc: true do
      params = { directory: "files", extension: "jpeg" }
      get_json "/v1/uploads/presign", params, as_user(@capt)
      expect_response(
        :ok,
        data: {
          path: String,
          upload_url: match(/\Ahttp.*jpeg\?X-Goog-Algorithm=.*\z/),
        },
      )
    end

    it "returns ok for files", doc: true do
      params = { directory: "files", extension: "jpg" }
      get_json "/v1/uploads/presign", params, as_user(@capt)
      expect_response(
        :ok,
        data: {
          path: String,
          upload_url: match(/\Ahttp.*jpg\?X-Goog-Algorithm=.*\z/),
        },
      )
    end

    it "returns ok for pdf files", doc: true do
      params = { directory: "files", extension: "pdf" }
      get_json "/v1/uploads/presign", params, as_user(@capt)
      expect_response(
        :ok,
        data: {
          path: String,
          upload_url: match(/\Ahttp.*pdf\?X-Goog-Algorithm=.*\z/),
        },
      )
    end

    it "returns error when directory is not exists", doc: true do
      params = { directory: "not-exist", extension: "pdf" }
      get_json "/v1/uploads/presign", params, as_user(@capt)
      expect_response(422)
    end
  end
end
