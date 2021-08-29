class QueryExecutionPolicy < ApplicationPolicy
  def show?
    user_in_same_company_as_query?
  end

  def result?
    user_in_same_company_as_query?
  end

  private

  def user_in_same_company_as_query?
    return false if @user.nil? || @record.nil?
    query_company = @record.company
    @user.companies.find { |c| c.id == query_company.id }.present?
  end
end
