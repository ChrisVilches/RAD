class CompanyPolicy < ApplicationPolicy
  def show?
    user_is_participating?
  end

  def user_is_participating?
    joined_company = @user.companies.find_by(id: @record.id)
    joined_company.present?
  end
end
