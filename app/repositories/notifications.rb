# frozen_string_literal: true

# Notifications
class Notifications < ApplicationRepository
  def see(id)
    return @scope.find(id).update seen: true if id.positive?

    @scope.update_all seen: true
  end

  private

  def default_scope
    ::Activity::Audience
      .joins(:activity)
      .references(:activity)
  end

  def load(scope, limit = nil)
    scope = scope.preload(:observer, activity: [:object, :context])
    # result = super(scope, limit)
    # ActiveRecord::Associations::Preloader.new.preload(
    #   result.map(&:activity).map(&:context).select { |c| c.is_a?(Applicant) }, [:career]
    # )
    # result
    super(scope, limit)
  end

  def filter_by_event(event)
    @scope.where("activities.event ILIKE '%#{event}%'")
  end

  def filter_by_seen(seen)
    @scope.where(seen: seen)
  end

  def filter_by_user_id(user_id)
    @scope.where(observer_id: user_id)
  end

  def filter_by_device_id(device_id)
    @scope.where(device_id: device_id)
  end

  # TODO: Should find another way to sort column dynamically
  def filter_by_sort_column(_sort_column)
    case sort_direction
    when "asc" then @scope.reorder(order_asc("id"))
    when "desc" then @scope.reorder(order_desc("id"))
    end
  end
end
