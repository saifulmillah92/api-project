class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.string :event
      t.integer :user_id
      t.integer :object_id
      t.string :object_type
      t.integer :context_id
      t.string :context_type
      t.json :metadata, default: {}

      t.timestamps null: false
    end

    create_table :activity_audiences do |t|
      t.string :context
      t.integer :activity_id
      t.integer :observer_id
      t.boolean :seen, default: false

      t.timestamps null: false
      t.index [:observer_id, :activity_id], unique: true
      t.index [:observer_id, :created_at], order: { created_at: :desc }
    end

    add_index :activities, [:object_type, :object_id]
    add_index :activities, [:context_type, :context_id]
    add_index :activities, :user_id
  end
end
