class ConnectionsController < AuthenticatedController
  include ActionController::Serialization
  include DatatablesProvider
  before_action :set_connection, only: %i[add_user remove_user update destroy]

  # TODO: Make sure to never render connection password in any controller and/or action.
  # Hopefully, block the attribute so that it's never rendered even if one accidentally
  # forgets to do something (such as using 'select' in a query).

  # GET /project/1/connections
  def index
    project = Project.find_by_id params[:project_id]
    authorize project.company, policy_class: ConnectionPolicy
    attributes = %i[id name description color host port user db_type used_times last_executed_at]
    connections = project.connections.select(*attributes).includes(:users, :queries).order(:id)
    render json: connections.map { |conn|
      conn.attributes.merge({
        users_count: conn.users.count,
        queries_count: conn.queries.count
      })
    }, status: :ok
  end

  def query_useable
    query = Query.find params[:query_id]
    project = query.project
    # TODO: Fix authorize
    # authorize project
    #columns = %i[id user_id connection_id query_id status error row_count created_at execution_started_at execution_ended_at]
    columns = %i[connection can_be_used]
    # TODO: Should use 'in_project' but the concern (delegate searchable) is failing at something.
    # It should work properly when including it in Connection model.
    results = Connection.where(project: project)

    render_table(
      columns: columns,
      results: results,
      sortable_columns: %i[id],
      row_transform: proc { |conn|
        {
          connection: {
            id: conn.id,
            name: conn.name,
            color: conn.color
          },
          can_use_connection: query.connections.include?(conn)
        }
      }
    )
  end

  # POST /project/1/connection/2/user/3
  def add_user
    user = User.find_by_id params[:user_id]

    # TODO: Implement!
    # authorize @connection

    # TODO: check and test this code.
    # Check the user to be added is in the same project as the connection.
    user_connection_match = user.project_participations.find { |pp| pp.project_id == @connection.project_id }

    if user_connection_match.nil?
      return render json: { msg: 'Not allowed. User and connection must be in the same project.' }, status: :unprocessable_entity
    end

    begin
      @connection.users << user
      return render json: {}, status: :ok
    rescue ActiveRecord::RecordNotUnique => e
      return render json: { msg: "It's already added." }, status: :ok
    end

    render json: {}, status: :unprocessable_entity
  end

  # DELETE /project/1/connection/2/user/3
  def remove_user
    user = User.find_by_id params[:user_id]
    @connection.users.delete(user)
    render json: {}, status: :ok
  end

  # POST /project/1/connections
  def create
    project = Project.find params[:project_id]
    conn = Connection.new(connection_params)
    conn.project = project

    # TODO: Implement!
    # authorize conn

    if conn.save
      render json: conn, include: :users, status: :created
    else
      render json: conn.errors, status: :unprocessable_entity
    end
  end

  def update
    # TODO: Implement!
    # authorize @connection
    if @connection.update(connection_params)
      render json: @connection
    else
      render json: @connection.errors, status: :unprocessable_entity
    end
  end

  def destroy
    # TODO: Implement!
    # authorize @connection
    @connection.destroy
    render json: { connection_id: @connection.id }, status: :ok
  end

  private

  def set_connection
    @connection = Connection.find params[:connection_id]
  end

  def connection_params
    params.require(:connection).permit(%i[name description user pass db_type host port color])
  end
end
