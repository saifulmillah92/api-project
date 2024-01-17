# frozen_string_literal: true

# UserPermission
class UserPermission < GeneralPermission
  def initialize(user, target_user)
    super(user, target_user)
    @target_user = target_user
  end

  private

  def see_owned_things?(visibility, _key: nil)
    return true if self?

    super(visibility)
  end

  def self?
    @user.id == @target_user.id
  end
end
