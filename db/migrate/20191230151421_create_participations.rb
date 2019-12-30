# These are participations of users in companies.
# The other one is per project.
# TODO Should name be changed to company_participations?

class CreateParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :participations do |t|
      t.boolean :super_permission, null: false, default: false
      t.boolean :project_permission, null: false, default: false
      t.boolean :connection_permission, null: false, default: false

      t.references :user, foreign_key: true, null: false
      t.references :company, foreign_key: true, null: false
    end

    add_index :participations, ["user_id", "company_id"], :unique => true
  end
end
