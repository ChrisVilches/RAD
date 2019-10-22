json.view do
  json.id @view.id
  json.name @view.name
  json.created_at @view.created_at
  json.updated_at @view.updated_at

  json.main_form_container do
    json.elements(@view.main_form_container.element_list) do |element|
      json.merge! element unless element.is_a?(Container)
      json.partial!(:containera, container: element) if element.is_a?(Container)
    end
  end

end
