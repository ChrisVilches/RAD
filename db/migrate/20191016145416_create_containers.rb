class CreateContainers < ActiveRecord::Migration[6.0]
  def change
    create_table :containers do |t|
      # Cannot be foreign constraint because it's polymorphic (could be views or queries tables, but also can be empty)
      t.references :inputable, null: true#, references: :elements
      #t.integer :inputable_id

      t.text :is_active, null: true
      t.string :inputable_type # Can be 'View' (view global container), 'Query' (query container), or empty (is nested and belongs to a container elements)
      t.timestamps
    end
  end
end
