# frozen_string_literal: true

module StoredFile
  class Gcs
    attr_reader :path

    def initialize(path, bucket)
      @bucket = bucket
      @path = path
    end

    def upload(content)
      @bucket.create_file content, @path
    end

    def upload_url
      @bucket.signed_url(path, method: "PUT", expires: 300, version: :v4)
    end

    def download_url
      file = @bucket.file(@path)
      return unless file

      file.signed_url method: "GET", expires: 300 # 5 minutes from now
    end

    def url
      "https://storage.googleapis.com/#{@bucket.name}/#{@path}"
    end
  end
end
