# TODO
# Since these files (with and without details) they can be put into one file
# and then use some @show_details flag to show details or not, and conditionally
# output the extra parts that are present in the detailed one.

json.view do
  json.id @view.id
  json.project_id @view.project_id
  json.name @view.name
  json.readme @view.readme
  json.created_at @view.created_at
  json.updated_at @view.updated_at

  json.container do
    json.partial!("container", container: @view.container)
  end

  json.queries(@view.queries.where(published: true)) do |query|
    json.id query.id
    json.name query.name
    json.latest_revision query.latest_revision
    json.log(query.query_histories.order(id: "desc").limit(5)) do |log|
      json.content log.content
      json.comment log.comment
    end
    json.description query.description
    json.container do
      json.partial!("container", container: query.container)
    end

    # Connections that are added to the query. This is needed for development
    # but not for execution. For execution, it's needed to know these connections
    # in addition to the ones the logged in user can execute.
    json.connections_allowed_to_query(query.connections) do |conn|
      json.id conn.id
      json.name conn.name
    end
  end

end
