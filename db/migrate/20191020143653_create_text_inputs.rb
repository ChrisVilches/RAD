class CreateTextInputs < ActiveRecord::Migration[6.0]
  def change
    create_table :text_inputs do |t|
      t.boolean :multiline, null: false
      t.string :regex, null: true
      t.integer :min, null: true
      t.integer :max, null: true
      t.boolean :required, null: false
      t.timestamps
    end
  end
end
