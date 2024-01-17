# frozen_string_literal: true

# Roles
class Roles < ApplicationRepository
  private

  def default_scope
    Role.includes(:permissions)
  end

  def filter_by_q(search)
    @scope.where("roles.name ILIKE '%#{search}%'")
  end
end
