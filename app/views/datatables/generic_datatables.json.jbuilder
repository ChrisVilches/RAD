json.data do
  json.array! data do |row|
    json.partial! row_partial, locals: { row: row }
  end
end
json.total data.total_count
json.columns columns
