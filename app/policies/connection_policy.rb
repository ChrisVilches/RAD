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

    raise "Record must be a Company" unless @record.is_a?(Company)

    joined_company = @user.participations.find_by(company_id: @record.id)

    return false if joined_company.nil?

    permission = joined_company.connection_permission
    permission ||= joined_company.super_permission
    return permission
  end

end
