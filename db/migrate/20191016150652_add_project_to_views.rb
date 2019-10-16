class AddProjectToViews < ActiveRecord::Migration[6.0]
  def change
    add_reference :views, :project, foreign_key: true
  end
end
