class CreateElements < ActiveRecord::Migration[6.0]
  def change
    create_table :elements do |t|
      t.references :elementable, references: :elements, null: false
      t.string :elementable_type, null: false
      t.references :container, foreign_key: true
      t.timestamps
    end
  end
end
