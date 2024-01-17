# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           null: false, default: ""
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Other informations
      t.string :first_name, default: ""
      t.string :last_name, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Others
      t.string :profile_picture
      t.string :state, null: false, default: "active"

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :username,             unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
