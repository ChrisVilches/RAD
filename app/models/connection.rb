class Connection < ApplicationRecord
  belongs_to :project

  def execute_query(sql)
    config = {
      adapter: "sqlite3",
      pool: 5,
      timeout: 5000,
      database: "db/test_remote_queries.sqlite3"
    }

    with_db(config) do
      ActiveRecord::Base.connection.execute(sql)
    end
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
