class CreateElements < ActiveRecord::Migration[6.0]
  def change
    create_table :elements do |t|
      # Cannot be foreign constraint because it's polymorphic (could be numeric_inputs, option_inputs tables, etc)
      t.references :elementable, null: false, references: :elements

      t.integer :position, null: false
      t.string :label, null: false, limit: 50
      t.string :variable_name, null: false, limit: 20
      t.string :elementable_type, null: false
      t.string :description, null: true
      t.references :container, foreign_key: { to_table: :containers, on_delete: :cascade }, null: false
      t.timestamps
    end

    add_index :elements, ["container_id", "position"], :unique => true
  end
end
