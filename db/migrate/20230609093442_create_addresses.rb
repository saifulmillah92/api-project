class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.integer :object_id, null: false
      t.string :object_type, null: false, default: ""
      t.string :street, limit: 100
      t.string :city, limit: 50
      t.string :state, limit: 50
      t.string :postal_code, limit: 20
      t.string :country, limit: 50
      t.string :phone_number, limit: 20
      t.text :additional_info

      t.timestamps
    end
    add_index :addresses, [:object_type, :object_id]
  end
end
