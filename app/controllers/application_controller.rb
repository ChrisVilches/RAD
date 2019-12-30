class ApplicationController < ActionController::API

  include Pundit

  # Execute always in order to catch not found company accounts.
  # The second time will be cached.
  before_action :current_company_id
  before_action :authenticate

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {}, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    render json: {}, status: :unauthorized
  end

  def authenticate

    # Fake login
    sign_in(User.first, scope: :user)

    user = current_user
    raise Pundit::NotAuthorizedError if user.nil?
  end

  def current_company_id

    return nil unless params.has_key?(:company_url)

    if @company_id
      return @company_id
    end
    company = Company.find_by(url: params[:company_url])
    if company.nil?
      raise ActiveRecord::RecordNotFound
    end
    @company_id = company.id
    return @company_id
  end
end
