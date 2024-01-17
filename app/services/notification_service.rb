# frozen_string_literal: true

# Notification Service
class NotificationService < AppService
  def initialize(user)
    super(user, nil, Notifications.new)
  end

  def all(query = {})
    my_notifications(query).limited.to_a
  end

  def unseen_count(query = {})
    my_notifications(query.merge(seen: false)).count
  end

  def see(query = {})
    my_notifications(query.merge(seen: false)).see(query[:id])
  end

  private

  def my_notifications(query = {})
    @repository.filter(query.merge(user_id: @user.id))
  end
end
