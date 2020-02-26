class Connection < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :users

  # TODO add user-defined description field to the connections table

  def execute_query(query, query_params = [], global_params = [])
    sql = query.build_sql(query_params, global_params)

    config = {
      adapter: "sqlite3",
      pool: 5,
      timeout: 5000,
      database: "db/test_remote_queries.sqlite3"
    }

    config = {
      adapter: "postgresql",
      pool: 5,
      timeout: 5000,
      database: "test_remote_queries"
    }

    result = []

    with_db(config) do
      # TODO This SQL separation is really bad.
      # This must be able to execute multi-sentence code.
      # There are many examples of codes that would crash if it can't.
      sql.split(";").each do |q|
        result = ActiveRecord::Base.connection.execute(q)
      end
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
