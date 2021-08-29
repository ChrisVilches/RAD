class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :published, null: false, default: true
      t.references :company, foreign_key: true, null: false
      t.timestamps
    end
  end
end
