class CreateViews < ActiveRecord::Migration[6.0]
  def change
    create_table :views do |t|
      t.string :name
      t.references :project, foreign_key: true, null: false
      t.text :readme, null: true
      t.boolean :published, null: false, default: true
      t.timestamps
    end
  end
end
