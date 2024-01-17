# frozen_string_literal: true

class UploadService < AppService
  FILE_MANAGERS = {
    image: {
      path: "%<file_type>s/%<random>s.%<file_format>s",
      file_types: ["pictures"],
      file_format: /\A(jpeg|jpg|png|)\z/,
      default_format: "jpg",
    },
    files: {
      path: "%<file_type>s/%<random>s.%<file_format>s",
      file_types: ["files"],
      file_format: /.+/,
    },
  }.freeze

  def initialize
    super(nil)
    @file_managers = FILE_MANAGERS.transform_values(&:dup)
  end

  def build_upload(params)
    assert! params.key?(:directory), on_error: "Key not found: directory"
    assert! params.key?(:extension), on_error: "Key not found: extension"
    file_params = {
      file_type: params.fetch(:directory), file_format: params.fetch(:extension),
    }
    file_manager = params[:file_manager]
    file_manager ||= find_file_manager file_params, :attachment, :image, :files
    path = build_filepath file_manager, file_params
    StoredFile.new(path)
  end

  private

  def find_file_manager(params, *manager_types)
    preprocess_params params
    file_managers = @file_managers
    file_managers = filter_managers(manager_types) if manager_types.any?

    key_val = file_managers.find do |_key, value|
      file_format = params[:file_format] || value[:default_format]
      value[:file_types].include?(params[:file_type]) &&
        (value[:file_format] =~ file_format)&.zero?
    end

    assert! key_val&.size == 2, on_error: "Invalid file type or format"
    key_val
  end

  def filter_managers(manager_types)
    @file_managers.select { |key| manager_types.include?(key) }
  end

  def preprocess_params(params)
    params[:file_type] = params[:file_type].to_s.strip.downcase.presence
    file_name = params[:file_name]
    file_name &&= file_name.tr(" ", "_").gsub(/[^a-zA-Z0-9._]+/, "")
    params[:file_name] = file_name

    file_format = ::File.extname(file_name)[n..] if file_name
    file_format ||= params[:file_format]
    params[:file_format] = file_format&.to_s&.strip&.downcase&.presence
    params
  end

  def build_filepath(file_manager, params)
    format_path(
      file_manager.second[:path],
      random: SecureRandom.uuid,
      file_name: params[:file_name],
      file_type: params[:file_type],
      file_format: params[:file_format],
    )
  end

  def format_path(path_format, path_params)
    format(path_format, path_params.compact)
  rescue KeyError => e
    key = e.message.match(/key\<(.+)\> not found/i).to_a.second
    raise Invalid, "Missing param #{key}"
  end
end
