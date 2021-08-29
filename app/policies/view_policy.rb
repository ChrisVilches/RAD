class ViewPolicy < ApplicationPolicy
  def show_without_details?
    project_participation = joined_project
    return false if project_participation.nil?

    project_participation.execution_permission || project_participation.develop_permission
  end

  def show_with_details?
    project_participation = joined_project
    return false if project_participation.nil?

    project_participation.develop_permission
  end

  def update?
    show_with_details? # Same as developer who can see with details
  end

  private

  def joined_project
    @user.project_participations.find_by(project_id: @record.project_id)
  end
end
