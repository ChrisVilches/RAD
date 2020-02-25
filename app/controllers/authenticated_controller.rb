class AuthenticatedController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit

  # TODO maybe this class could have more stuff like...
  # Before every action get the company, project, etc. Get everything
  # in the URL, because the URL always contains all of that, and there are
  # a few controllers that have to be manually fetching that data all the time,
  # which wastes code space.

  before_action :authenticate_user!
  before_action :ensure_user_joined_company

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {}, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    render json: {}, status: :unauthorized
  end

  # Fake login
  def current_user
    User.first
  end

  def current_company

    return nil unless params.has_key?(:company_url)

    if @company
      return @company
    end

    @company = Company.find_by(url: params[:company_url])
    if @company.nil?
      raise ActiveRecord::RecordNotFound
    end

    return @company
  end

  def ensure_user_joined_company
    unless CompanyPolicy.new(current_user, current_company).user_is_participating?
      raise Pundit::NotAuthorizedError
    end
  end

end
