# frozen_string_literal: true

# Config Service
class ConfigService < AppService
  def initialize(user)
    super(user, Config)
  end

  def all(params = {})
    configs(params[:type])
  end

  def update(_id, params = {})
    authorize! can?(:update, @service)

    new_configs = params&.stringify_keys || {}
    configs = @service.where(key: new_configs.keys)
    transaction do
      update_config(new_configs, configs)
      record_other_configs(new_configs, configs)
    end

    Config.to_h
  end

  private

  def update_config(new_configs, configs)
    configs.each do |config|
      value = new_configs[config.key]
      config.update(value: value) if config.value != value
    end
  end

  def record_other_configs(new_configs, configs)
    actually_new_config_keys = new_configs.keys - configs.pluck(:key)
    actually_new_configs = new_configs.slice(*actually_new_config_keys)

    attributes = []
    actually_new_configs.each do |key, value|
      attributes << { key: key, value: value }
    end

    @service.import(attributes)
  end

  def can_execute?
    permission?(
      @user.superadmin?,
      access_values: ["all"],
      access_permissions: ["settings.configs.manage"],
      current_permissions: Current.permissions,
    )
  end

  def configs(type)
    case type
    when "contact_us" then Current.configs.slice(*contact_us_key)
    else Current.configs
    end
  end

  def contact_us_key
    data = []
    data.push(:email, :website, :address1, :address2, :phone, :whatsapp)
    data.push(:instagram_url, :youtube_url, :facebook_url, :google_map_url)
    data
  end
end
