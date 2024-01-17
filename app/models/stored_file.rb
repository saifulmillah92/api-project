# frozen_string_literal: true

module StoredFile
  module_function

  MAIN_BUCKET_SET = BucketSet.public_bucket

  def download_url(uri)
    new(uri)&.download_url
  end

  def new(uri)
    uri = canonicalize(uri)

    stored_file(self::MAIN_BUCKET_SET, uri)
  end

  def stored_file(bucket_set, uri)
    return unless bucket_set&.match?(uri)

    path = bucket_set.path(uri)
    Gcs.new(path, bucket_set.storage)
  end

  def canonicalize(uri)
    uri = uri.dup
    uri.strip!
    uri
  end
end
