# frozen_string_literal: true

# Module for setting up throttles
module RackAttackThrottles
  module_function

  def self.env(key, default)
    ENV[key].blank? ? default : ENV[key].presence.to_i.clamp(0, Float::INFINITY)
  end

  CONFIG = [
    {
      name: "limit commenting",
      limit: env("LIMIT_COMMENTING", 2),
      period: env("LIMIT_COMMENTING_PERIOD", 1.minute.to_i),
      identifier: :user_identifier,
      endpoints: [
        { method: Rack::POST, path: %r{/posts/\d+/comments\z} },
      ],
    },
    {
      name: "limit login attempt by ip",
      limit: env("LIMIT_LOGIN_IP", 10),
      period: env("LIMIT_LOGIN_IP_PERIOD", 2.seconds.to_i),
      identifier: :ip,
      endpoints: [
        { method: Rack::POST, path: %r{/auth/sign-in} },
        # { method: Rack::POST, path: %r{/auth/[^/]+(/sign-in)?\z} },
      ],
    },
    {
      name: "limit login attempt by email",
      limit: env("LIMIT_LOGIN_EMAIL", 3),
      period: env("LIMIT_LOGIN_EMAIL_PERIOD", 30.seconds.to_i),
      identifier: :email,
      endpoints: [
        { method: Rack::POST, path: %r{/auth/sign-in} },
      ],
    },
    {
      name: "limit password reset by ip",
      limit: env("LIMIT_RESET_PASSWORD_IP", 3),
      period: env("LIMIT_RESET_PASSWORD_IP_PERIOD", 5.minutes.to_i),
      identifier: :ip,
      endpoints: [
        { method: Rack::POST, path: %r{/auth/forgot-password} },
        { method: Rack::POST, path: %r{/auth/reset-password} },
      ],
    },
    {
      name: "limit password reset by email",
      limit: env("LIMIT_RESET_PASSWORD_EMAIL", 3),
      period: env("LIMIT_RESET_PASSWORD_EMAIL_PERIOD", 15.minutes.to_i),
      identifier: :email,
      endpoints: [
        { method: Rack::POST, path: %r{/auth/forgot-password} },
        { method: Rack::POST, path: %r{/auth/reset-password} },
      ],
    },
  ].freeze

  def each
    CONFIG.each { |config| yield(self, config) }
  end

  def user_identifier(_req)
    Current.user.id
  end

  def match?(req, endpoints)
    endpoints.any? do |endpoint|
      req.request_method == endpoint[:method] && req.path =~ endpoint[:path]
    end
  end

  def ip(req)
    (req.env["action_dispatch.remote_ip"] || req.ip).to_s
  end

  def email(req)
    email = req.params["email"]
    return email if email || req.get?

    body = req.body.read
    req.body.rewind
    return if body.blank?

    params = JSON.parse(body)
    params["email"]
  end
end

Rack::Attack.throttled_response = lambda do |env|
  # NB: you have access to the name and other data about the matched throttle
  #  env['rack.attack.matched'],
  #  env['rack.attack.match_type'],
  #  env['rack.attack.match_data'],
  #  env['rack.attack.match_discriminator']

  # Consider 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 429 for throttling by default
  period = env["rack.attack.match_data"][:period]

  if period >= 60
    duration = period / 60
    unit = "minutes"
  else
    duration = period
    unit = "seconds"
  end

  [
    429,
    { "Content-Type" => "application/json" },
    [
      %({
        "errors": {"code": 429, "message": "Too many request, try again in #{duration} #{unit}."},
        "error": {"code": 429, "message": "Too many request, try again #{duration} #{unit}."}
      }),
    ],
  ]
end

RackAttackThrottles.each do |throttle, config|
  name = config[:name]
  params = config.slice(:limit, :period)
  endpoints = config[:endpoints]
  identifier = config[:identifier]

  next if params[:limit].zero?
  next if params[:period].zero?

  Rack::Attack.throttle(name, params) do |req|
    next if ENV["DISABLE_THROTTLE"].present?
    next unless throttle.match?(req, endpoints)

    throttle.__send__(identifier, req)
  end
end

Rails.application.config.middleware.delete Rack::Attack
