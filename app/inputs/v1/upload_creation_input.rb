# frozen_string_literal: true

module V1
  class UploadCreationInput < ::ApplicationInput
    strip_unknown_attributes

    required(:object_id)
    required(:object_type)
    required(:directory)
    required(:extension)
    required(:file)
  end
end
