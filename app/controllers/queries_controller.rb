class QueriesController < AuthenticatedController
  before_action :set_query, only: [:show, :update, :destroy, :execute]

  # GET /queries
  def index
    # TODO authorize
    view = View.where(project_id: params[:project_id], id: params[:view_id]).first
    @queries = view.queries
    render json: @queries
  end

  # GET /queries/1
  def show
    # TODO authorize
    render json: @query, include: :content
  end

  # POST /project/1/view/2/query/3/add_connection
  def add_connection
    conn = Connection.find_by_id params[:connection_id]
    query = Query.find_by_id params[:query_id]
    query.connections << conn
    render json: query.connections, status: :ok
  end

  # DELETE /project/1/view/2/query/3/remove_connection
  def remove_connection
    conn = Connection.find_by_id params[:connection_id]
    query = Query.find_by_id params[:query_id]
    query.connections.delete conn
    render json: query.connections, status: :ok
  end

  # POST /queries
  def create

    view = View.where(id: params[:view_id], project_id: params[:project_id]).first
    # TODO must authorize view before creating a query for it
    @query = view.queries.create query_params
    authorize @query

    if @query
      render json: @query, status: :created# TODO, location: @query
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  # POST /query/1/execute
  def execute

    authorize @query

    conn = Connection.find_by_id params[:connection_id]

    # TODO validate connection and its permissions against user

    global_user_input = params[:global]
    query_user_input = params[:query]

    begin

      result = conn.execute_query(@query, query_user_input, global_user_input)
      render json: result

    rescue Query::IncorrectParams => e
      render json: {
        global_form_errors: e.global_form_errors,
        query_form_errors: e.query_form_errors
      }, status: :unprocessable_entity

    rescue Query::HasParamsNotReplaced => e
      render json: {
        param_names: e.param_names
      }, status: :internal_server_error
    end
  end

  # PATCH/PUT /queries/1
  def update

    authorize @query.view

    query = params.require :query

    comment = query[:comment] || ""
    config_version = params[:config_version]
    code = query[:code] || ""

    new_container = Container.build_from_hash({ elements: query.require(:container)[:elements] })

    # Container is incorrect, so return error information
    unless new_container.valid?
      render json: new_container.error_structure, status: :unprocessable_entity
      return
    end

    save_result = false

    ActiveRecord::Base.transaction do
      @query.container.destroy! unless @query.container.nil?
      @query.container = new_container
      if @query.save
        if @query.latest_revision.nil? || @query.latest_revision.content["sql"] != code
          @query.query_histories << QueryHistory.new(comment: comment, config_version: config_version, content: { sql: code })
        end
        logger.debug @query.container.to_debug_s
        render json: @query
        return
      end
    end

    render json: @query.errors, status: :unprocessable_entity
  end

  # DELETE /queries/1
  def destroy
    authorize @query
    @query.destroy
    render json: @query
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:query_id])
    end

    # Only allow a trusted parameter "white list" through.
    def query_params
      params.require(:query).permit(:name, :description)
    end

    def query_history_params
      params.require(:query_history).permit([:comment, :config_version, :content])
    end
end
