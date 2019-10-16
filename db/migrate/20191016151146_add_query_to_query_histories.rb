class AddQueryToQueryHistories < ActiveRecord::Migration[6.0]
  def change
    add_reference :query_histories, :query, foreign_key: true
  end
end
