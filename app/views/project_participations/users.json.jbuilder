json.array! users do |row|
  json.partial! 'project_participations/users_in_project', locals: { row: row }
end
