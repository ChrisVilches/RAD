class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      t.references :view, null: true, foreign_key: true
      t.text :is_active, null: true
      t.timestamps
    end
  end
end
