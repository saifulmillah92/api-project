# frozen_string_literal: true

# AppService
class AppService < ApplicationService
  def initialize(user, service = nil, repository = nil)
    super
    @user = user
    @service = service
    @repository = repository
  end

  def all(query = {})
    authorize! can?(:see_all, @service)
    @repository.filter(query).limited.to_a
  end

  def find(id)
    @service = @service.find(id)
    authorize! can?(:see, @service)
    @service
  end

  def find_by(query = {})
    @service.find_by(query)
  end

  def new(query = {})
    @service.new(query)
  end

  def create(query = {})
    authorize! can?(:create, new(query))

    transaction do
      service = @service.create!(query)
      service
    end
  end

  def update(id, query = {})
    @service = find(id)
    authorize! can?(:update, @service)

    transaction { @service.update!(query) && @service }
  end

  def destroy(id)
    @service = find(id)
    authorize! can?(:destroy, @service)

    if @service.respond_to?(:soft_deleted!)
      @service.soft_deleted! && @service
    else
      @service.destroy! && @service
    end
  end

  def count(params = {})
    @repository.filter(params).to_a.size
  end

  def mark_as_seen!(context_type)
    ::Activity::Audience
      .joins(:activity)
      .where(activity_audiences: { observer_id: @user.id })
      .find_by(activities: { context_type: context_type, context_id: @service.id })
      &.update seen: true
  end

  def validate!(input)
    return unless input
    raise ActiveRecord::RecordInvalid, input if input.errors.any?
    raise ActiveRecord::RecordInvalid, input unless input.valid?

    input
  end

  def can?(action, object)
    @user.permission_on(object).send("#{action}?")
  end

  class NotFound < ::StandardError
  end

  class Unauthenticated < ::StandardError
  end

  class Unauthorized < ::StandardError
  end

  class Invalid < ::StandardError
  end

  class Throttled < ::StandardError
  end
end
