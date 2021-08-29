json.executions_percentage_users do
  json.array! @executions_percentage_users do |tuple|
    json.id tuple[:user].id
    json.email tuple[:user].email
    json.executions_percentage tuple[:executions_percentage] 
  end
end
