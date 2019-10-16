class AddProjectToConnections < ActiveRecord::Migration[6.0]
  def change
    add_reference :connections, :project, foreign_key: true
  end
end
