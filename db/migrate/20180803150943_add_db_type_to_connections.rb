class AddDbTypeToConnections < ActiveRecord::Migration[6.0]
  def change
    add_column :connections, :db_type, :integer, null: false, default: 0
    reversible do |dir|
      dir.up do
        change_column :connections, :db_type, :integer, null: false, default: nil
      end
      dir.down do
        change_column :connections, :db_type, :integer, null: false, default: 0
      end
    end
  end

  def down
    remove_column :connections, :db_type
  end
end

# Note: db_type ends up being:
#   null: false
#   default: nil (must be set manually)
