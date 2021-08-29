json.queries_with_most_errors do
  json.array! @queries_with_most_errors do |query|
    json.partial! 'query', query: query
  end
end
