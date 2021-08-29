class QueryPolicy < ApplicationPolicy
  def execute?
    project_participation = joined_project
    return false if project_participation.nil?

    return project_participation.execution_permission
  end

  def create?
    project_participation = joined_project
    return false if project_participation.nil?

    return project_participation.develop_permission
  end

  def destroy?
    create?
  end

  def update?
    create?
  end

  private

  def joined_project
    @user.project_participations.find_by(project_id: @record.view.project_id)
  end
end
