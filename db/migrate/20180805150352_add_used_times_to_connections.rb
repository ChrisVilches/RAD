class AddUsedTimesToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :used_times, :integer, default: 0, null: false
  end
end
