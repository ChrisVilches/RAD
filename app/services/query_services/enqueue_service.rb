module QueryServices
  class EnqueueService
    def initialize(user, conn)
      @user = user
      @conn = conn
    end

    def enqueue(query, query_history, query_params, global_params, perform = true)
      # TODO: Clean and remove extra data from query_params and global_params.
      #       There's already a lot of logic implemented related to this (containers, elementables, etc).
      #       Don't save extra data that came from the scary internet!.
      execution = QueryExecution.new(
        user: @user,
        query: query,
        query_history: query_history,
        connection: @conn,
        query_params: query_params,
        global_params: global_params
      )
      execution.save!
      QueryExecutorWorker.perform_async(execution.id) if perform
      execution.id
    end
  end
end
