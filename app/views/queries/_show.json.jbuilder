json.id query.id
json.name query.name

if details
  json.latest_revision query.latest_revision
  json.log(query.query_histories.order(id: 'desc').limit(5)) do |log|
    json.content log.content
    json.comment log.comment
  end
end

json.view_id query.view_id
json.project_id query.project.id
json.description query.description
json.container do
  json.partial!('queries/container', container: query.container)
end

# Connections that the user can execute.
json.connections_allowed_to_user(query.connections_allowed_to(current_user)) do |conn|
  json.id conn.id
  json.name conn.name
  json.color conn.color
end

# Connections that can be used by this query.
json.connections_allowed_to_query(query.connections) do |conn|
  json.id conn.id
  json.name conn.name
  json.color conn.color
end
