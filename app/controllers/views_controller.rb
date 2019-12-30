class ViewsController < AuthenticatedController
  before_action :set_view, only: [:show_without_details, :show_with_details, :update, :destroy]

  # GET /views
  def index
    @views = View.where(project_id: params[:project_id], published: true)
    render json: @views
  end

  # GET /views/1
  # For users without developer permissions.
  # They cannot see details such as SQL code, etc.
  def show_without_details
    authorize @view
  end

  # GET /views/1/details
  # For users with developer permissions.
  def show_with_details
    authorize @view
  end

  # POST /views
  def create
    project = Project.find params[:project_id]
    @view = project.views.create view_params

    if @view
      render json: @view, status: :created# TODO, location: @view
    else
      render json: @view.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /views/1
  def update
    if @view.update(view_params)
      render json: @view
    else
      render json: @view.errors, status: :unprocessable_entity
    end
  end

  # DELETE /views/1
  def destroy
    @view.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_view
      @view = View.find(params[:view_id])
    end

    # Only allow a trusted parameter "white list" through.
    def view_params
      params.require(:view).permit(:name, :readme)
    end
end
