class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.references :object, polymorphic: true
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :permissions, [:key, :object_type, :object_id], unique: true
  end
end
