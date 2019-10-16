class AddViewToQueries < ActiveRecord::Migration[6.0]
  def change
    add_reference :queries, :view, foreign_key: true
  end
end
