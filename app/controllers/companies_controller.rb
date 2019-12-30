class CompaniesController < ApplicationController
  before_action :set_company, only: [:show]
  # TODO test this controller
  # GET /companies
  def index
  end

  # GET /companies/slug
  def show
    render json: @company
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find_by(id: current_company_id)
  end

end
