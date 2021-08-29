require 'active_support/concern'

module Tabulatable
  extend ActiveSupport::Concern

  module ClassMethods
    # (Other params are self-explanatory)
    # @param keyword_searchable_columns [Symbol Array] Columns where the LIKE '%keyword%' should be performed on.
    # @result [ActiveRecord_Relation]
    def filter_by_table_params(p:, per_page:, keyword_searchable_columns: nil, sort_by: :id, sort_by_dir: :asc, keyword: nil)
      query = page(p).per(per_page)
      query = query.order(by_column(sort_by, sort_by_dir)) if sort_by.present?

      raise "Not allowed to sort using column: #{sort_by}" if columns_with_index.exclude?(sort_by)

      if keyword.present?
        searchable_columns = string_type_columns
        searchable_columns.intersection!(keyword_searchable_columns) if keyword_searchable_columns.present?
        # No row matches because no column is searchable.
        return query.none if searchable_columns.empty?
        query = query.where(filter_by_keyword(searchable_columns, keyword))
      end

      query
    end

    def columns_with_index
      # TODO: LOL THIS IS SO WRONG!!!!!!!!!!!!!!!!!
      # remove 'query_executions'
      [:id] + ActiveRecord::Base.connection.indexes(:query_executions).map(&:columns).flatten.map(&:to_sym)
    end

    private

    def by_column(column, asc_desc)
      direction = asc_desc || :asc

      sort_map = { column => direction } if column_names.include?(column.to_s)

      # If the column to sort is not ID, and column ID exists, then use it as secondary sort field (with same direction).
      sort_map[:id] = direction if column != :id && column_names.include?('id')
      sort_map
    end

    def filter_by_keyword(searchable_columns, keyword)
      searchable_columns.map { |col| arel_table[col].matches("%#{keyword}%") }.inject(&:or)
    end

    def string_type_columns
      # Postgres Array type cannot have LIKE '%keyword%'.
      # So, this removes array-type columns as well.
      columns_hash.map { |k, v| { name: k, type: v.type, array: v.array? } }
                  .select { |col| col[:type] == :string && !col[:array] }
                  .pluck(:name)
                  .map(&:to_sym)
    end
  end
end
