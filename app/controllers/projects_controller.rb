class ProjectsController < AuthenticatedController
  before_action :set_project, only: %i[show summary update destroy project_connections favorite unfavorite assign_permission_batch]
  before_action :assign_permission_batch_param!, only: %i[assign_permission_batch]
  MAX_BATCH_USER = 100

  # GET /projects
  # TODO: Implement pagination only when it becomes necessary.
  # i.e. when a user actually has several dozens of projects.
  def index
    project_participations = current_user.project_participations.includes(:project)
    projects = Project.where(company: current_company).order(id: :desc)
    projects = projects.map do |proj|
      participation = project_participations.find { |pp| pp.project_id == proj.id  }
      access_attribute = {
        access: participation.present?,
        favorite: participation.present? && participation.favorite
      }
      proj.attributes.merge(access_attribute)
    end
    projects.sort_by! { |proj| proj[:favorite] ? 0 : 1 }
    render json: projects
  end

  def summary
    authorize @project
    summary_service = ProjectServices::SummaryService.new @project

    @last_days_activity = summary_service.last_days_activity(days: 30)
    @most_used_queries = summary_service.most_used_queries(max: 10, days: 100)
    @queries_with_most_errors = summary_service.queries_with_most_errors(max: 10, days: 50)
    @executions_percentage_users = summary_service.executions_percentage_users(max: 10, days: 100)
  end

  # GET /project/1
  def show
    authorize @project
    result = @project.attributes

    result[:company_permissions] = current_user.company_permissions(@project.company)
    result[:project_permissions] = current_user.project_permissions(@project)

    result[:participants_count] = @project.users.count

    # TODO: Only show connection count if user can see them. (permissions... or better using scopes?)
    result[:connections_count] = @project.connections.count

    # TODO: Show total view count if user can see them (even unpublished ones), or only published ones
    # if the user doesn't have enough permissions to see them.
    result[:views_count] = @project.views.where(published: true).count

    render json: result
  end

  def assign_permission_batch
    # TODO: The logic here has to be analyzed more carefully.
    # Can a user remove permissions to himself?
    # Can a user remove permissions to a super user?
    # How is this operation authorized?

    project_participations = @project.project_participations.where(user_id: params[:user_ids])

    # TODO: Optimize batch query (low priority).
    project_participations.map do |pp|
      pp.update "#{params[:permission_type]}_permission" => params[:assign]
    end

    users_changed = User.where(id: params[:user_ids])
    render 'project_participations/users', locals: { users: users_changed }
  end

  def favorite
    toggle_favorite true
  end

  def unfavorite
    toggle_favorite false
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.company = current_company
    authorize @project

    if @project.save
      # Add user that created the project as participant.
      @project.users << current_user
      render json: @project, status: :created
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
    # TODO: Implement!
    # authorize @project
    @project.destroy
  end

  private

  def assign_permission_batch_param!
    param! :permission_type, String, in: %i[execution develop publish], transform: :to_sym
    param! :assign, Boolean
    param! :user_ids, Array, min_length: 0, max_length: MAX_BATCH_USER, transform: :uniq do |array, index|
      array.param! index, Integer, required: true
    end
  end

  def toggle_favorite(val)
    authorize @project
    project_participation = current_user.project_participations.where(project: @project).first
    project_participation.update(favorite: val)
    render json: {
      project_id: project_participation.project_id,
      favorite: project_participation.favorite
    }, status: :ok
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find_by(id: params[:project_id], company_id: current_company.id)
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.require(:project).permit(%i[name description published])
  end
end
