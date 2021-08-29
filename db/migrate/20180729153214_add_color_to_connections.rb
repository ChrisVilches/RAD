class AddColorToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :color, :integer
  end

  def down
    remove_column :connections, :color
  end
end
