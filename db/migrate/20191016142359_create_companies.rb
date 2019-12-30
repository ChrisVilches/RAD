class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false, limit: 50
      t.string :url, null: false, limit: 50
      t.timestamps
    end

    add_index :companies, :url, :unique => true
  end
end
