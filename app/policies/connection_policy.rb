class ConnectionPolicy < ApplicationPolicy

  def index?
    can_manage_connections?
  end

  def create?
    can_manage_connections?
  end

  def add_user?
    can_manage_connections?
  end

  private

  def can_manage_connections?

    if @record.is_a?(Project)
      company_id = @record.company_id
    elsif @record.is_a?(Connection)
      company_id = @record.project.company_id
    elsif @record.is_a?(Company)
      company_id = @record.id
    else
      raise "Error. Incorrect type."
    end

    joined_company = @user.participations.find_by(company_id: company_id)
    permission = joined_company.connection_permission
    permission ||= joined_company.super_permission
    !joined_company.nil? && permission
  end

end
