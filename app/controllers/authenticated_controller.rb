class AuthenticatedController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit

  helper_method :current_company

  # TODO: maybe this class could have more stuff like...
  # Before every action get the company, project, etc. Get everything
  # in the URL, because the URL always contains all of that, and there are
  # a few controllers that have to be manually fetching that data all the time,
  # which wastes code space.

  before_action :authenticate_user!
  before_action :ensure_user_joined_company

  rescue_from ActiveRecord::RecordNotFound do
    render json: {}, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: {}, status: :unauthorized
  end

  # Fake login
  def current_user
    u = User.find 1
    cp = u.participations.first
    pp = u.project_participations.where(project_id: 1).first
    raise 'incorrect' if pp.project_id != 1
    cp.connection_permission = true
    cp.super_permission = true
    cp.project_permission = true

    #pp.execution_permission = true
    #pp.develop_permission = true
    #pp.publish_permission = true
    cp.save
    #pp.save
    u
  end

  def current_company
    return nil unless params.key?(:company_url)
    return @company if @company

    @company = Company.find_by(url: params[:company_url])
    raise ActiveRecord::RecordNotFound if @company.nil?

    @company
  end

  def ensure_user_joined_company
    return if current_company.nil?
    unless CompanyPolicy.new(current_user, current_company).user_is_participating?
      raise Pundit::NotAuthorizedError
    end
  end
end
