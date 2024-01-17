# frozen_string_literal: true

module V1
  class UploadsController < ::ApplicationController
    before_action :initialize_global_variable!

    def create
      input = V1::UploadCreationInput.new(request_body)
      validate! input

      stored_file = upload_file_based_on_klass(input.output)
      render_json stored_file, V1::UploadOutput
    end

    def presign
      upload_params = params.slice(:public, :extension, :directory)
      stored_file = ::UploadService.new.build_upload(upload_params)
      render_json stored_file, version::UploadOutput
    end

    private

    def upload_file_based_on_klass(input)
      object_class = input[:object_type]
      case object_class
      when "User" then add_profile_picture(input)
      end
    end

    def add_profile_picture(input)
      user = User.find(input[:object_id])
      stored_file = service.build_upload(input)
      stored_file.upload(params[:file].tempfile)

      user.update! profile_picture: stored_file.url

      stored_file
    end

    def service
      UploadService.new
    end

    def default_output
      Outputs::Api
    end
  end
end
