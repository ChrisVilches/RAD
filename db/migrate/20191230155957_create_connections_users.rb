class CreateConnectionsUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :connections_users do |t|
      t.references :user, foreign_key: true, null: false
      t.references :connection, foreign_key: true, null: false
    end

    add_index :connections_users, ["user_id", "connection_id"], :unique => true
  end

  def down
    drop_table :connections_users
  end
end
