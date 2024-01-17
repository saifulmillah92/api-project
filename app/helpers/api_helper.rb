# frozen_string_literal: true

module ApiHelper
  def t(data, **options)
    I18n.t(data, **options)
  end

  def secure_random_hex(size = 30)
    SecureRandom.hex(size)
  end

  def to_struct(datas)
    JSON.parse(datas&.to_json, object_class: OpenStruct)
  end

  def all_dates(start_at, end_at, strftime = "%b %d")
    dates = (Date.parse(start_at)..Date.parse(end_at)).to_a
    dates.map { |date| date.strftime(strftime) }
  end
end
