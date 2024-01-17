# frozen_string_literal: true

# Activities
class Activities < ApplicationRepository
  sort_by :id, :desc

  private

  def default_scope
    Activity.joins(:audiences).includes(:audiences, :user).preload(:context, :object)
  end

  def filter_by_observer_id(observer_id)
    @scope.where(activity_audiences: { observer_id: observer_id })
  end

  def filter_by_seen(seen)
    @scope.where(activity_audiences: { seen: seen })
  end
end
