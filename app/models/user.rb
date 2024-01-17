# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  SUPERADMINS = ["hr@yourdomain.com", "superadmin@yourdomain.com"].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :validatable

  has_many :permissions, through: :roles

  alias authenticate valid_password?

  enum state: string_enum("active", "inactive", "deleted")

  has_one :address,
          class_name: "Address",
          as: :object,
          inverse_of: :object,
          dependent: :destroy,
          autosave: true

  accepts_nested_attributes_for :address

  scope :available, -> { excluded_superadmins.where(state: "active") }
  scope :excluded_superadmins, -> { where.not(email: SUPERADMINS) }

  def fullname
    "#{first_name} #{last_name}".strip
  end

  def superadmin?
    email.in?(SUPERADMINS)
  end

  def role
    roles.last
  end

  def current_permissions
    p = permissions.map { |ps| { ps[:key] => ps[:value] } }
    p = filtered_permission(p)

    Permission.defaults.each { |k, v| p[k] ||= superadmin? ? "true" : v }
    p.sort.to_h
  end

  def permission_on(object)
    case object
    when User then UserPermission.new(self, object)
    else GeneralPermission.new(self, object)
    end
  end

  def filtered_permission(permissions)
    filtered_data = {}

    permissions.each do |item|
      item.each do |key, value|
        filtered_data[key] = value if filtered_data[key].nil?
        filtered_data[key] = "true" if value == "true"
      end
    end

    filtered_data
  end
end
