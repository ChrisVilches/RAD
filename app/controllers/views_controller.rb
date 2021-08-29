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
    @details = false
    render 'views/show'
  end

  # GET /views/1/details
  # For users with developer permissions.
  def show_with_details
    authorize @view
    @details = true
    render 'views/show'
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

    begin
      update_container!
      @view.update view_params
    rescue ContainerErrors::IncorrectContainerError => e
      return render json: e.container_errors, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid
      return render json: @view.errors, status: :unprocessable_entity
    end

    render json: @view
  end

  # DELETE /views/1
  def destroy
    @view.destroy
  end

  private

  # @raise [ContainerErrors::IncorrectContainerError] When the container has errors (e.g. format, structure, etc).
  # @raise [ActiveRecord::RecordInvalid] When the container cannot be saved.
  def update_container!
    container = container_params
    return unless container.present?

    new_container = Container.build_from_hash({ elements: container[:elements] })

    raise ContainerErrors::IncorrectContainerError, new_container.error_structure unless new_container.valid?

    ActiveRecord::Base.transaction do
      @view.container.destroy!
      @view.container = new_container
      logger.debug @view.container.to_debug_s
      @view.save!
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_view
    @view = View.find(params[:view_id])
  end

  def view_params
    params.require(:view).permit(:name, :description)
  end

  def container_params
    view = params.require(:view)
    return nil unless view.key?(:container)
    view.require(:container)
  end
end
