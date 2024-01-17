# frozen_string_literal: true

module V1
  # Notification Presenter
  class NotificationPresenter < ApiPresenter
    def nano_presentation
      {
        id: @object.id,
        seen: @object.seen,
        notification_type: notification_type,
      }
    end

    def contextual_presentation
      {
        id: @object.id,
        seen: @object.seen,
        notification_type: notification_type,
        text: text,
        resource: activity_service.resource(object),
        icon: activity_service.icon(activity.context_type),
        created_at: @object.created_at.to_formatted_s(:long_ordinal),
      }
    end

    def ui_presentation
      contextual_presentation.merge(link_to: link_to)
    end

    private

    def link_to
      "#{splitted_object_type}/#{object&.id}"
    end

    def splitted_object_type
      data = activity.object_type.split(/(?=[A-Z])/) * "_"
      data.pluralize.downcase
    end

    def notification_type
      case activity.event
      when /users/ then "user"
      end
    end

    def activity
      @object.activity
    end

    def text
      title, message = activity_service.text(activity)
      { title: title, message: message }
    end

    def object
      @object.activity.object
    end

    def activity_service
      ActivityService.new(current_user)
    end

    def current_user
      @options[:current_user]
    end
  end
end
