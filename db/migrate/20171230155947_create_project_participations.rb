class CreateProjectParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :project_participations do |t|
      t.boolean :execution_permission, null: false, default: false
      t.boolean :develop_permission, null: false, default: false
      t.boolean :publish_permission, null: false, default: false

      t.references :user, foreign_key: true, null: false
      t.references :project, foreign_key: true, null: false
    end

    add_index :project_participations, ["user_id", "project_id"], :unique => true
  end
end
