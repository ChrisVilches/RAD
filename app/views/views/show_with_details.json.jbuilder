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
    json.connections query.connections
  end

end
