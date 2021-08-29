class QueryExecutorWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0

  # @param id [Integer] ID of QueryExecution object.
  def perform(id)
    query_execution = QueryExecution.find(id)
    notify_status(query_execution)

    begin_execution(id)

    begin
      result = do_execute(query_execution)
      save_results(id, result)
      end_with_success(id, result.fields, result.count)
      notify_status(query_execution)
    rescue => e
      end_with_error_code(id, default_error)
      notify_status(query_execution, e)
      raise e
    end

    nil
  end

  private

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/query_executor.log.#{Rails.env}")
  end

  def notify_status(query_execution, e = nil)
    query_execution.reload
    view = query_execution.query.view
    status = query_execution.status
    error = query_execution.error
    notification_message = {
      query_execution_id: query_execution.id,
      query_id: query_execution.query_id,
      status: status,
      error: error
    }.compact
    ViewNotificationChannel.broadcast_to(view, notification_message)

    notification_message.merge!({ exception: e, error_message: e.message }) if e.present?
    logger.debug(notification_message)
    e.backtrace.each { |line| logger.debug line } if e.present?
  end

  def default_error
    QueryExecution.errors[:unknown_error]
  end

  def client(connection)
    config = {
      host: connection.host, username: connection.user, password: 'rails5dev', database: 'daijob5_development'
    }

    # TODO: Add more DB types.
    raise 'Only mysql is implemented' unless connection.mysql?
    Mysql2::Client.new(config)
  end

  def do_execute(query_execution)
    query_history = query_execution.query_history
    conn = query_execution.connection

    query_params = query_execution.query_params
    global_params = query_execution.global_params
    sql = QueryServices::SqlBuilderService.build_sql(query_history, query_params, global_params)
    conn.increase_used_times!
    client(conn).query(sql)
  end

  def begin_execution(id)
    QueryExecution.find(id).update execution_started_at: DateTime.now, status: QueryExecution.statuses[:progress]
  end

  def finish_execution(id)
    QueryExecution.find(id).update({
                                     execution_ended_at: DateTime.now,
                                     status: QueryExecution.statuses[:finished]
                                   })
  end

  def end_with_error_code(id, error)
    finish_execution(id)
    QueryExecution.find(id).update error: error
  end

  def end_with_success(id, headers, row_count)
    finish_execution(id)
    QueryExecution.find(id).update headers: headers, row_count: row_count
  end

  def save_results(id, result)
    # TODO: Optimize so it uses less extra memory.
    QueryExecutionResult.collection.insert_many(result.map { |row| { query_execution_id: id, row_content: row } })
  end
end
