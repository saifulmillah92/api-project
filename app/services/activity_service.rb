# frozen_string_literal: true

# Activity Service
class ActivityService < AppService
  def initialize(user)
    super(user, Activity, Activities.new)
    @locale = locale_activities
  end

  def text(activity)
    creator = activity.user
    event = activity.event.tr(".", "_")
    texts = @locale["notification_#{event}"]
    raise StandardError, "Unhandled notification event: #{event}" unless texts

    title = title_params(creator, activity.context, activity.context_type)
    message = message_params(creator, activity.context, activity.context_type)

    [texts["title"] % title, texts["message"] % message]
  end

  def resource(object)
    case object
    when User then { id: object.id, type: "user" }
    end
  end

  def icon(context_type)
    icons[context_type]
  end

  private

  def title_params(_creator, context, context_type)
    case context_type
    when "User" then [context.fullname]
    else raise StandardError, "Unhandled notification object type #{context.class}"
    end
  end

  def message_params(creator, context, context_type)
    case context_type
    when "User" then ["**#{username}**", "**#{creator.fullname}**"]
    else raise StandardError, "Unhandled notification object type #{context.class}"
    end
  end

  def locale_activities
    YAML.load_file(Rails.root.join("config/locales/activities.yml"))
  end

  def icons
    {
      "User" => "fas fa-fw fa-user",
    }
  end

  def username
    @user&.first_name&.titleize || "User"
  end
end
