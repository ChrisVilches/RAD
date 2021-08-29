class CreateConnectionsQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :connections_queries do |t|
      t.references :query, foreign_key: true, null: false
      t.references :connection, foreign_key: true, null: false
    end

    add_index :connections_queries, ["query_id", "connection_id"], :unique => true
  end

  def down
    drop_table :connections_queries
  end
end
