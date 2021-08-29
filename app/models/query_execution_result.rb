class QueryExecutionResult
  include Mongoid::Document
  field :query_execution_id, type: Integer
  field :row_content, type: Hash
end
