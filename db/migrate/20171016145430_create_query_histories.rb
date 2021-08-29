class CreateQueryHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :query_histories do |t|
      t.string :comment
      t.integer :config_version
      t.json :content
      t.references :query, foreign_key: true
      t.timestamps
    end
  end
end
