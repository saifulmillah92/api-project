# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Knock::Authenticable
  include ApiHelper
  delegate :permission?, to: GeneralPermission
  before_action :restrict_request_to_specific_host
  before_action :authenticate_user

  use Rack::Attack

  rescue_from StandardError do |error|
    log_error(error)
    render_json error,
                Outputs::Exception,
                debug: !Rails.env.production?,
                namespace: controller_path
  end

  private

  def default_output
    Outputs::Api
  end

  def render_json(model, klass = default_output, **options)
    output = klass.new(model, options)
    capture_failure(output)
    render json: output.root_json, status: output.status
  end

  def render_error(model_or_string, **options)
    render_json(model_or_string, Outputs::Error, **options)
  end

  def render_empty_json(model, klass = EmptyOutput, **options)
    render_json(model, klass, **options)
  end

  def render_json_array(array, klass = default_output, **options)
    output = klass.array(array, **options)
    render json: output.root_json, status: output.status
  end

  def render_ok(options = { message: t("ok") })
    render json: { code: 200, message: options[:message] }, status: :ok
  end

  def render_created(options = { message: t("ok") })
    render json: { code: 201, message: options[:message] }, status: :created
  end

  def render_route_not_found
    render json: { error: { code: 404, message: t("route_not_found") } },
           status: :not_found
  end

  def capture_failure(output)
    return unless output.error?
    return unless output.options[:capture_failure]

    message = "Failure: #{controller_path}##{action_name}"
    capture_message(message, extra: { response: output.as_json })
  end

  def log_error(resource)
    Rails.logger.error(
      "resouce_errors => #{resource.message}\n" \
      "file => #{resource.backtrace.first.split(":")&.first}\n" \
      "line => #{resource.backtrace.first.split(":")&.second}",
    )
  end

  def validate!(model, on_error = {})
    halt! render_json(model, **on_error) unless Array(model).all?(&:valid?)

    model
  end

  def authorize!(*truths, on_error: t("not_allowed"))
    raise ApplicationService::Unauthorized, on_error if truths.none?
  end

  def initialize_global_variable!
    Current.user = current_user
    Current.permissions = current_user.current_permissions

    initialize_global_limit_offset_variable!
  end

  def initialize_global_limit_offset_variable!
    Current.limit = (params[:limit] ||= 10).to_i
    Current.offset = params[:offset].to_i
    Current.page = params[:page].to_i
  end

  def class_exists?(class_name)
    klass = Module.const_get(class_name)
    klass.is_a?(Class)
  rescue NameError
    false
  end

  def restrict_request_to_specific_host
    return if Rails.env.test?

    allowed_hosts = ENV.fetch("ALLOWED_HOSTS", []).split(",")
    host = request.host.split(".").last
    return if allowed_hosts.any? { |url| host.in?(url) }

    render_error("Unauthorized Host", status: :unauthorized)
  end

  def version
    v = request.params[:__version]
    case v
    when :v1 then V1
    else render_error("Invalid API version #{v.truncate(5)}", status: 404)
    end
  end

  def versions
    ["v1"]
  end

  def params
    request.params
  end

  def query_params
    @query_params ||= request.query_parameters.symbolize_keys
  end

  def request_body
    @request_body ||=
      request.request_parameters
             .symbolize_keys
             .except(controller_name.singularize.to_sym)
  end

  def can?(keys, access_values = ["true"])
    permission?(
      current_user.superadmin?,
      access_values: Array(access_values),
      access_permissions: Array(keys),
      current_permissions: Current.permissions,
    )
  end

  private def halt!(*_)
    throw(:halt_controller)
  end

  private def catch_halt(&block)
    catch(:halt_controller, &block)
  end

  around_action :catch_halt
end
