class AddLastExecutedAtToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :last_executed_at, :datetime, default: nil
  end

  def down
    remove_column :connections, :last_executed_at
  end
end
