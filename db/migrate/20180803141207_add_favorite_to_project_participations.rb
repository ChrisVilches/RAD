class AddFavoriteToProjectParticipations < ActiveRecord::Migration[6.0]
  def change
    add_column :project_participations, :favorite, :boolean, null: false, default: false
  end

  def down
    remove_column :project_participations, :favorite
  end
end
