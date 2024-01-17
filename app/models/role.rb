class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  has_many :permissions,
           class_name: "Permission",
           as: :object,
           inverse_of: :object,
           dependent: :destroy,
           autosave: true

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  accepts_nested_attributes_for :permissions
end
