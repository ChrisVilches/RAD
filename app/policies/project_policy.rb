class ProjectPolicy < ApplicationPolicy
  def index?
    false
  end

  def create?
    # First check if the user belongs to that company (the one to which the project will be created).
    # Then check whether he can make a project.

    participation = @user.participations.find_by(company_id: @record.company_id)
    return false if participation.nil?

    participation.project_permission
  end

  def show?
    user_participates_in_project?
  end

  def favorite?
    user_participates_in_project?
  end

  def unfavorite?
    user_participates_in_project?
  end

  def summary?
    user_participates_in_project?
  end

  private

  def user_participates_in_project?
    joined_project = @user.project_participations.find_by(project_id: @record.id)
    joined_project.present?
  end
end
