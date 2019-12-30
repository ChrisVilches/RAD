class ProjectPolicy < ApplicationPolicy
  def create?

    # First check if the user belongs to that company (the one to which the project will be created).
    # Then check whether he can make a project.

    participation = @user.participations.find_by(company_id: @record.company_id)
    return false if participation.nil?

    return participation.project_permission

  end
end
