class ProjectsController < AuthenticatedController
  before_action :set_project, only: [:show, :update, :destroy, :project_connections]

  # GET /projects
  def index
    @projects = policy_scope(Project).where(company: current_company)
    render json: @projects
  end

  # GET /project/1
  def show
    authorize @project
    result = @project.attributes

    result[:company_permissions] = current_user.company_permissions(@project.company)
    result[:project_permissions] = current_user.project_permissions(@project)

    result[:participants_count] = @project.users.count

    # TODO Only show connection count if user can see them. (permissions)
    result[:connections_count] = @project.connections.count
    result[:views_count] = @project.views.count

    render json: result
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.company = current_company
    authorize @project

    if @project.save
      # Add user that created the project as participant.
      @project.users << current_user
      render json: @project, status: :created# TODO , location: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /project/1
  def update
    if @project.update(project_params)
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /project/1
  def destroy
    @project.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find_by(id: params[:project_id], company_id: current_company.id)
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project).permit([:name, :readme])
    end
end
