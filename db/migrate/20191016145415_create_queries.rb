class CreateQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :queries do |t|
      t.integer :execution_count, default: 0, null: false
      t.numeric :average_time, default: 0
      t.date :last_execution, default: nil
      t.boolean :active, default: true, null: false
      t.references :view, foreign_key: true, null: false
      t.timestamps
    end
  end
end
