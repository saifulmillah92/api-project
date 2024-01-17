# frozen_string_literal: true

module V1
  class UploadOutput < Outputs::Api
    def format
      {
        path: @object.path,
        url: @object.url,
        upload_url: @object.upload_url,
      }
    end
  end
end
