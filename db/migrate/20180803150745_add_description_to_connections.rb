class AddDescriptionToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :description, :integer, null: true, limit: 200
  end

  def down
    remove_column :connections, :description
  end
end
