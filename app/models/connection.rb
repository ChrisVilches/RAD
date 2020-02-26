class Connection < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :users

  # TODO add user-defined description field to the connections table
  # TODO also add validations and restrictions in the migration for other fields (string length, null false, etc)

  def execute_query(query, query_params = [], global_params = [])
    # The following contains the actual code (final SQL code) that will
    # be executed on the server.
    sql = query.build_sql(query_params, global_params)

    config = {
      adapter: "postgresql",
      pool: 1, # TODO Understand correctly what exactly is a pool.
      timeout: 5000,
      database: "test_remote_queries"
    }

    result = nil

    with_db(config) do
      result = ActiveRecord::Base.connection.execute(sql)
    end
    return result
  end

  private
  def with_db(db_config)
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(db_config)
    yield
    ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end


end
