json.view do
  json.id @view.id
  json.project_id @view.project_id
  json.name @view.name
  json.created_at @view.created_at
  json.updated_at @view.updated_at

  json.main_form_container do
    json.partial!("container", container: @view.main_form_container)
  end

end
