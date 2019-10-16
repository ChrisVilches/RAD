class AddConfigToQueries < ActiveRecord::Migration[6.0]
  def change
    add_column :queries, :config, :json
  end
end
