class AddPreviousContentToQueryHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :query_histories, :previous_content, :string
  end
end
