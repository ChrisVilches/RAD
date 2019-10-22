class CreateElements < ActiveRecord::Migration[6.0]
  def change
    create_table :elements do |t|
      t.references :elementable, references: :elements, null: false
      t.integer :position, null: false
      t.string :elementable_type, null: false
      t.references :container, foreign_key: true, null: false
      t.timestamps
    end

    add_index :elements, ["container_id", "position"], :unique => true
  end
end
