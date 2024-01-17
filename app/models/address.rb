# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :object, polymorphic: true

  after_initialize { self.object ||= object unless persisted? }
end
