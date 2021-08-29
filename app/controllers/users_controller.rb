class UsersController < AuthenticatedController
  include DatatablesProvider
  before_action :set_project, only: %i[project_users]
  before_action :set_connection, only: %i[connection_users]

  # TODO: Move some queries to a User 'scope'.

  def connection_users
    # TODO: Implement!
    # authorize @connection

    columns = %i[user can_use_connection]
    results = User.joins(:project_participations)
                  .where(project_participations: { project: @connection.project })
                  .includes(:connections)

    render_table({
                   columns: columns,
                   results: results,
                   row_transform: proc { |user|
                     {
                       # With this, in Datatables it's possible to render something like <a href="/user/:id">email</a>
                       # without having to show the ID in a column.
                       user: { id: user.id, email: user.email },
                       can_use_connection: user.connections.include?(@connection)
                     }
                   }
                 })
  end

  def project_users
    # TODO: Implement!
    # authorize @project

    # This query might be slow (or maybe not), but at least it's paginated.
    # If it's too slow, add more indexes, and optimize a bit.
    columns = %i[id user_type execution_permission develop_permission publish_permission]

    # Filter by 'participating in company'
    results = User.joins(:participations)
                  .includes(:participations, :project_participations)
                  .where(participations: { company: current_company })

    # Filter by 'participating in project'
    if only_users_participating_in_project?
      results = results.joins(:project_participations)
                       .where(project_participations: { project: @project })
    end

    render_datatables_with_row_partial({
                                         columns: columns,
                                         data: results,
                                         row_partial: 'project_participations/users_in_project'
                                       })
  end

  private

  # For scoping the query so that only participating users are shown,
  # set this flag to true.
  #
  # If it's false, then all company users will be shown, along with a 'participating'
  # (in the current project) column indicating whether they are added to the project or not.
  def only_users_participating_in_project?
    params.key?(:only_in_project) && params[:only_in_project] == 'true'
  end

  def set_connection
    @connection = Connection.find params[:connection_id]
  end

  def set_project
    @project = Project.find params[:project_id]
  end
end
