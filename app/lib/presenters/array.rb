# frozen_string_literal: true

module Presenters
  # Array
  class Array < Presenters::Basic
    def initialize(objects, **options)
      super()
      @object = objects.is_a?(Response::Object) ? objects.data : objects
      @options = options.dup
      @options[:status] = infer_status(options[:status])
    end

    def element_presenter
      @options[:presenter]
    end

    private

    def presentation
      @object.map { |o| element_presenter.new(o, @options) }
    end

    def presentation_method
      :presentation
    end

    def root_key
      element_presenter.root
    end
  end
end
