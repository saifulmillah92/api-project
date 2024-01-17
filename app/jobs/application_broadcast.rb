# frozen_string_literal: true

class ApplicationBroadcast < ApplicationJob
  queue_as :default

  def perform(user_id)
    @user = User.find(user_id)
    Current.user = @user

    yield
  rescue StandardError => e
    broadcast_to(@user, broadcast_name, nil, **error_message(e))
    @result = nil # prevent from multiple broadcast
  ensure
    broadcast_to(@user, broadcast_name, object, errors: errors) if @result
  end

  private

  def service; end
  def broadcast_name; end
  def errors; end
  def object; end
end
