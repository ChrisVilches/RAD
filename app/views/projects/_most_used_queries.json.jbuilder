json.most_used_queries do
  json.array! @most_used_queries do |query|
    json.partial! 'query', query: query
  end
end
