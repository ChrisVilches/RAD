class AddDescriptionToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :description, :string, null: true, limit: 1000
  end

  def down
    remove_column :projects, :description
  end
end
