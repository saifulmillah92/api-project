# frozen_string_literal: true

module V1
  class ActivityPresenter < ApiPresenter
    private

    def nano_presentation
      {
        id: @object.id,
        created_at: @object.created_at,
        event: @object.event,
      }
    end
  end
end
