# frozen_string_literal: true

require "google/cloud/storage"

module StoredFile
  class BucketSet
    class << self
      def public_bucket
        new(ENV.fetch("GCS_BUCKET_NAME", nil))
      end
    end

    attr_reader :storage

    delegate :name, to: :storage

    def initialize(bucket)
      @storage = bucket(bucket)
    end

    def bucket(bucket)
      params = { project_id: project_id, credentials: credentials }
      Google::Cloud::Storage.new(**params).bucket(bucket)
    end

    def match?(uri)
      return true if uri.starts_with?(target_url)
      return false if uri.match?(/\Ahttps?:/)

      true
    end

    def path(uri)
      path = uri.dup
      path.gsub!(target_url, "")
      path.gsub!(/\A\//, "")

      CGI.unescape(path)
    end

    def target_url
      "https://storage.googleapis.com/#{name}"
    end

    def credentials
      {
        private_key_id: ENV.fetch("GCS_PRIVATE_KEY_ID", nil),
        private_key: ENV.fetch("GCS_PRIVATE_KEY", nil),
        client_email: ENV.fetch("GCS_CLIENT_EMAIL", nil),
        client_id: ENV.fetch("GCS_CLIENT_ID", nil),
      }
    end

    def project_id
      ENV.fetch("GCS_PROJECT_ID", nil)
    end
  end
end
