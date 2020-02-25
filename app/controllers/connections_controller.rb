class ConnectionsController < AuthenticatedController

  # GET /project/1/connections
  def index
    project = Project.find_by_id params[:project_id]
    connections = project.connections
    authorize connections
    # TODO should render the connections only the user can see I guess...
    # and also only if the user has permissions to see connections at all.
    render json: connections, include: :users, status: :ok
  end

  # POST /project/1/connection/2/add_user
  def add_user
    conn = Connection.find_by_id params[:connection_id]
    user = User.find_by_id params[:user_id]

    # TODO check and test this code.
    # Check the user to be added is in the same project as the connection.
    user_connection_match = user.project_participations.find{|pp| pp.project_id == conn.project_id}

    if user_connection_match.nil?
      return render json: { msg: "Not allowed. User and connection must be in the same project." }, status: :unprocessable_entity
    end

    begin
      conn.users << user
      return render json: conn, status: :ok
    rescue ActiveRecord::RecordNotUnique => e
      return render json: { msg: "It's already added." }, status: :ok
    end

    render json: {}, status: :unprocessable_entity
  end

  # POST /project/1/connections
  def create
    project = Project.find_by_id params[:project_id]
    conn = Connection.new(project: project)
    conn.attributes = params.permit([:user, :pass, :host, :port])
    authorize conn

    if conn.save
      render json: conn, status: :created
    else
      render json: conn, status: :unprocessable_entity
    end
  end

end
