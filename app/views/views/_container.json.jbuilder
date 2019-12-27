json.elements(container.nil? ? [] : container.elements) do |element|

  json.variable_name element.variable_name
  json.id element.id
  json.elementable_type element.elementable_type.to_s

  if element.elementable_type == Container.to_s

    container = element.elementable
    json.partial!("container", container: container)
    json.is_active container.is_active
  else
    json.label element.label
    json.description element.description
    json.params element.elementable.as_json except: [:id, :updated_at, :created_at]
  end

end
