# frozen_string_literal: true

# General Permission
class GeneralPermission
  class << self
    def permission?(
      admin_access = nil,
      access_values: nil,
      access_permissions: nil,
      current_permissions: nil
    )
      return true if admin_access
      return admin_access unless access_permissions
      return admin_access unless access_values

      access_permissions.any? do |key|
        access_values.include?(current_permissions[key])
      end
    end
  end

  def initialize(user, object)
    @user = user
    @object = object
    @permissions = Current.permissions
  end

  def see_all?
    see_owned_things?(@permissions["#{model_name}.index"])
  end

  def see?
    see_owned_things?(@permissions["#{model_name}.show"])
  end

  def create?
    see_owned_things?(@permissions["#{model_name}.create"])
  end

  def update?
    see_owned_things?(@permissions["#{model_name}.update"])
  end

  def destroy?
    see_owned_things?(@permissions["#{model_name}.destroy"])
  end

  private

  def see_owned_things?(visibility, _key: nil)
    return true if superadmin?

    visibility == "true"
  end

  def model_name
    name = @object.is_a?(Class) ? @object.name : @object.class.name
    name = name.pluralize.split(/(?=[A-Z])/) * "_"
    name.downcase
  end

  def superadmin?
    @user.superadmin?
  end
end
