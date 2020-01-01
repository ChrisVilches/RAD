class CreateOptionInputs < ActiveRecord::Migration[6.0]
  def change
    create_table :option_inputs do |t|
      t.integer :component_type, null: false
      t.jsonb :options, null: false
      t.boolean :required, null: false, default: false
      t.timestamps
    end
  end
end
