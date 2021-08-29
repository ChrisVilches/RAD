class QueryExecutionsController < AuthenticatedController
  include DatatablesProvider
  before_action :set_query_execution, only: %i[result show]

  MANY_ROWS = 320

  def index
    project = Project.find params[:project_id]
    # TODO: Fix authorize
    # authorize project
    columns = %i[id user_id connection_id query_id status error row_count created_at execution_started_at execution_ended_at]
    results = QueryExecution.includes(:connection, :user)
                            .in_project(project)

    row_transform = proc do |query_execution|
      user = query_execution.user
      connection = query_execution.connection
      {
        id: query_execution.id,
        user_id: user.id,
        user: {
          email: user.email
        },
        connection_id: {
          id: connection.id,
          color: connection.color,
          name: connection.name
        },
        query_id: query_execution.query_id,
        created_at: query_execution.created_at,
        execution_started_at: query_execution.execution_started_at,
        execution_ended_at: query_execution.execution_ended_at,
        status: query_execution.status,
        error: query_execution.error,
        row_count: query_execution.row_count
      }
    end

    render_table results: results, row_transform: row_transform, columns: columns
  end

  # Specification for sending table data to the user:
  # If the row count is 'small', then send everything and allow the user to perform sorting and pagination on the frontend.
  # If the row count is 'big', then don't allow sorting (because tables have arbitrary structure, no indexes can be added,
  # thus sorting a 100000+ row table will be slow, so disable this functionality), and allow server-side pagination.
  # Server-side pagination can be done efficiently because it only uses LIMIT and OFFSET (the equivalent in MongoDB though),
  # so no indexes are needed.
  #
  # TODO: However, whether MongoDB works this way or not has to be confirmed.
  # i.e. Can LIMIT+OFFSET be done quickly in MongoDB without indexes?
  #
  # TODO: Handle large header count, and large cell values (including large header names).
  # One way of doing it is by examining the 'headers' value after the query is performed, and throw an error
  # if there's any huge one.
  # Something similar can be done for the entire size of each row after executing the query and getting its results.
  def result
    authorize @query_execution

    return render_not_yet_processed if processing?

    count = document_query.count
    MANY_ROWS < count ? result_with_pagination : result_without_pagination
  end

  def show
    authorize @query_execution
    render json: @query_execution
  end

  private

  def render_not_yet_processed
    render json: { status: @query_execution.status, msg: 'Processing not yet complete. Poll or try again later.' }
  end

  def processing?
    @query_execution.idle? || @query_execution.progress?
  end

  def document_query
    QueryExecutionResult.where(query_execution_id: @query_execution.id)
  end

  def clean_results(query)
    query.collect { |row| row[:row_content] } # TODO: Optimize if possible.
  end

  def result_with_pagination
    # TODO: Must also render total count, so the frontend can paginate.
    # TODO: Currently, it's not fully tested and/or implemented.
    paginated_query = document_query.page(3).per(6)
    rows = clean_results(paginated_query)
    render json: { page: true, headers: @query_execution.headers, rows: rows }
  end

  def result_without_pagination
    rows = clean_results(document_query)
    render json: { page: false, headers: @query_execution.headers, rows: rows }
  end

  def set_query_execution
    @query_execution = QueryExecution.find params[:query_execution_id]
  end
end
