json.elements(container.elements) do |element|

  if element.elementable_type == Container.to_s
    json.elementable_type Container.to_s
    json.partial!("container", container: element.elementable)
  else
    json.elementable_type element.elementable_type.to_s
    json.params element.elementable.as_json except: [:id, :updated_at, :created_at]
  end

end
