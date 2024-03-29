json.elements(container.nil? ? [] : container.elements) do |element|
  json.variable_name element.variable_name
  json.id element.id
  json.elementable_type element.elementable_type.to_s
  json.label element.label

  if element.elementable_type == Container.to_s
    container = element.elementable
    json.partial!('queries/container', container: container)
    json.params element.elementable.as_json only: [:is_active]
  else
    json.description element.description
    json.params element.elementable.as_json except: %i[id updated_at created_at]
  end
end
