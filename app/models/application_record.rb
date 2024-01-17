# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include ApiHelper
  primary_abstract_class

  class << self
    def string_enum(*strings)
      strings.map { |s| [s, s] }.to_h
    end
  end

  class Invalid < ::StandardError
  end

  class NotAllowed < ::StandardError
  end
end
