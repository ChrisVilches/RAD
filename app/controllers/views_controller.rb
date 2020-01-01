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
    raise "Write policy!!!"
    @view = nil # CREATE as empty

    if @view
      render json: @view, status: :created# TODO, location: @view
    else
      render json: @view.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /views/1
  def update
    authorize @view

    elements = params.require(:view).require(:container).require(:elements)

    ActiveRecord::Base.transaction do
      raise "IMPLEMENT THIS"
      @view.container.destroy!

    end

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

end
