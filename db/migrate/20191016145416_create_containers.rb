class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      t.integer :inputable_id
      t.text :is_active, null: true
      t.string :inputable_type
      t.timestamps
    end
  end
end
