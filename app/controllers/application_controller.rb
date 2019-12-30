class ApplicationController < ActionController::API

  include Pundit

  before_action :fake_login
  before_action :ensure_user_is_logged_in
  before_action :ensure_user_joined_company

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {}, status: :not_found
  end

  rescue_from Pundit::NotAuthorizedError do |exception|
    render json: {}, status: :unauthorized
  end

  def fake_login
    sign_in(User.first, scope: :user)
  end

  def ensure_user_is_logged_in
    user = current_user
    raise Pundit::NotAuthorizedError if user.nil?
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
