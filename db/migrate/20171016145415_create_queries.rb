class CreateQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :queries do |t|
      t.integer :execution_count, default: 0, null: false
      t.numeric :average_time, default: 0
      t.date :last_execution, default: nil
      t.references :view, foreign_key: true, null: false
      t.string :name, null: false
      t.string :description, null: true
      t.boolean :published, null: false, default: true
      t.timestamps
    end
  end
end
