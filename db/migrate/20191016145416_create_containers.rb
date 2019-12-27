class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      #t.references :view, null: true, foreign_key: true
      #t.references :query, null: true, foreign_key: true
      t.integer :inputable_id
      t.text :is_active, null: true
      t.string :inputable_type
      t.timestamps
    end
  end
end
