# frozen_string_literal: true

module V1
  # Api Presenter
  class ApiPresenter < Presenters::Base
    def self.root
      :data
    end

    def presentation
      @object.as_json
    end
  end
end
