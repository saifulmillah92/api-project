# frozen_string_literal: true

class Activity < ApplicationRecord
  self.table_name = "activities"

  belongs_to :user, optional: true
  belongs_to :object, polymorphic: true
  belongs_to :context, polymorphic: true

  has_many :audiences, dependent: :destroy

  after_initialize { self.context ||= object unless persisted? }
  after_initialize { self.object ||= context unless persisted? }

  class Audience < ApplicationRecord
    self.table_name = "activity_audiences"
    enum context: string_enum("author", "target", "audience")

    scope :after, ->(timestamp) { where(arel_table[:created_at].gt(timestamp)) }
    scope :from_newest, -> { order(created_at: :desc) }

    belongs_to :activity
    belongs_to :observer, class_name: "User"

    validates :observer, presence: true, uniqueness: { scope: [:activity] }
  end
end
