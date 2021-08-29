module ProjectServices
  class SummaryService
    def initialize(project)
      @project = project
    end

    def queries_with_most_errors(max:, days:)
      query_ids = latest_executions(days: days).select(:query_id, 'count(*) as count')
                                               .where(status: 'finished')
                                               .where('error is not null')
                                               .limit(max)
                                               .order('count desc')
                                               .group(:query_id)
                                               .collect(&:query_id)
      Query.where(id: query_ids).includes(:view)
    end

    def last_days_activity(days:)
      # For summary by hour, use '%Y-%m-%d %H'
      counts = latest_executions(days: days).map { |qe| qe.created_at.strftime('%Y-%m-%d') }
                                            .tally

      dates_array = []
      counts.keys.each do |date|
        dates_array << {
          date: date,
          count: counts[date]
        }
      end

      dates_array.sort_by { |date| date[:date] }
    end

    def executions_percentage_users(max:, days:)
      queries = latest_executions(days: days).to_a
      count = queries.count
      group_by_user_id_counts = queries.collect(&:user_id).tally
      users = User.find group_by_user_id_counts.keys

      clean_result = users.map do |u|
        user_id = u.id
        percentage = ((group_by_user_id_counts[user_id] / count.to_f) * 100).truncate(3)
        { user: u, executions_percentage: percentage }
      end

      # TODO: Test with more users
      clean_result.sort_by { |u| u[:executions_percentage] }[0, max]
    end

    def most_used_queries(max:, days:)
      counts = {}
      latest_executions(days: days).select(:id, :query_id).each do |qe|
        counts[qe.query_id] = 0 unless counts.key?(qe.query_id)
        counts[qe.query_id] += 1
      end
      query_ids = counts.to_a
                        .sort_by(&:last)
                        .reverse[0, max] # Sort desc & get max elements
                        .collect(&:first) # Get only ID
      Query.where(id: query_ids).includes(:view)
    end

    private

    def latest_executions(days:)
      queries = Query.joins(:view).where(views: { project: @project })
      QueryExecution.where(query: queries)
                    .where(created_at: (DateTime.now - days.days)..)
    end
  end
end
