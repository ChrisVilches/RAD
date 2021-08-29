class AddQueryHistoryToQueryExecutions < ActiveRecord::Migration[6.0]
  def change
    add_reference :query_executions, :query_history, foreign_key: true
  end
end
