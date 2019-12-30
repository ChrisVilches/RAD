class QueryPolicy < ApplicationPolicy
  def execute?
    joined_project = @user.project_participations.find_by(project_id: @record.view.project_id)
    return false if joined_project.nil?

    return joined_project.execution_permission
  end
end
