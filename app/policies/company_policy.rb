class CompanyPolicy < ApplicationPolicy
  def user_is_participating?
    joined_company = @user.companies.find_by(id: @record.id)
    !joined_company.nil?
  end
end
