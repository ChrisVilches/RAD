class CreateElements < ActiveRecord::Migration[6.0]
  def change
    create_table :elements do |t|
      t.references :elementable, null: false, references: :elements, on_delete: :cascade
      t.integer :position, null: false
      t.string :label, null: false, limit: 50
      t.string :variable_name, null: false, limit: 20
      t.string :elementable_type, null: false
      t.string :description, null: true
      t.references :container, foreign_key: true, null: false, on_delete: :cascade
      t.timestamps
    end

    add_index :elements, ["container_id", "position"], :unique => true
  end
end
