class QueriesController < AuthenticatedController
  before_action :set_query, only: [:show, :update, :destroy, :execute]

  # GET /queries
  def index
    view = View.where(project_id: params[:project_id], id: params[:view_id]).first
    @queries = view.queries
    render json: @queries
  end

  # GET /queries/1
  def show
    render json: @query, include: :content
  end

  # POST /queries
  def create

    view = View.where(id: params[:view_id], project_id: params[:project_id]).first
    @query = view.queries.create query_params

    if @query
      render json: @query, status: :created# TODO, location: @query
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  # POST /query/1/execute
  def execute

    authorize @query

    conn = Connection.new

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

    comment = params[:comment] || ""
    config_version = params[:config_version],
    content = params[:content]

    new_revision = @query.query_histories << QueryHistory.new(comment: comment, config_version: config_version, content: content)

    if new_revision
      render json: @query, include: :content
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  # DELETE /queries/1
  def destroy
    @query.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:query_id])
    end

    # Only allow a trusted parameter "white list" through.
    def query_params
      params.require(:query).permit(:code)
    end

    def query_history_params
      params.require(:query_history).permit([:comment, :config_version, :content])
    end
end
