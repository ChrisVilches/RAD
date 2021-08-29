class CompaniesController < AuthenticatedController
  before_action :set_company, only: [:show]
  # TODO: test this controller
  # GET /companies
  def index
    render json: current_user.companies
  end

  # GET /companies/slug
  def show
    authorize @company
    permissions = current_user.company_permissions(@company)
    render json: @company.attributes.merge(permissions)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = current_company
  end
end
