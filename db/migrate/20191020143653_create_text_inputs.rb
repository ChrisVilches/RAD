class CreateTextInputs < ActiveRecord::Migration[6.0]
  def change
    create_table :text_inputs do |t|
      t.timestamps
    end
  end
end
