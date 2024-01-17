# frozen_string_literal: true

module Presenters
  # Error
  class Error < Presenters::Basic
    def self.root
      nil
    end

    private

    def presentation
      { error: { code: status, message: @object } }
    end

    def presentation_method
      :presentation
    end
  end
end
