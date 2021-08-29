class AddParamsToQueryExecutions < ActiveRecord::Migration[6.0]
  def change
    add_column :query_executions, :query_params, :jsonb, null: true, default: nil
    add_column :query_executions, :global_params, :jsonb, null: true, default: nil
  end
end
