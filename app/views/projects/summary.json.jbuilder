json.project do
  json.id @project.id
  json.name @project.name
end
json.partial! 'last_days_activity'
json.partial! 'most_used_queries'
json.partial! 'queries_with_most_errors'
json.partial! 'executions_percentage_users'
