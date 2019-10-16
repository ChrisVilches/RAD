class CreateQueryHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :query_histories do |t|
      t.string :comment

      t.timestamps
    end
  end
end
