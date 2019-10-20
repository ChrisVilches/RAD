class CreateElements < ActiveRecord::Migration[6.0]
  def change
    create_table :elements do |t|
      t.integer :elementable_id
      t.string :elementable_type
      t.references :container, foreign_key: true
      t.boolean :required
      t.timestamps
    end
  end
end
