class CreateConnections < ActiveRecord::Migration[6.0]
  def change
    create_table :connections do |t|
      t.string :name
      t.string :user
      t.string :pass
      t.string :host
      t.string :port

      t.timestamps
    end
  end
end
