class CreateQueryExecutions < ActiveRecord::Migration[6.0]
  def change
    create_table :query_executions do |t|
      t.references :query, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :connection, foreign_key: true, null: false
      t.datetime :execution_started_at, precision: 6, null: true
      t.datetime :execution_ended_at, precision: 6, null: true
      t.string :headers, array: true, default: '{}'
      t.integer :status, null: false, default: QueryExecution.statuses[:idle]
      t.integer :error, null: true, default: nil
      t.integer :row_count, null: false, default: 0
      t.integer :size, null: false, default: 0
      t.date :results_expired_at, default: nil
      t.timestamps
    end
  end

  def down
    drop_table :query_executions
  end
end
