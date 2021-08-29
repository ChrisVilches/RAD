require 'active_support/concern'

module DatatablesProvider
  extend ActiveSupport::Concern
  MAX_PAGE_SIZE = 100
  DATATABLES_PARAMS = %i[p per_page sort_by sort_by_dir keyword].freeze

  def table_params
    handle_params!
    params.permit(*DATATABLES_PARAMS).to_h.symbolize_keys
  end

  # @param results [ActiveRecord_Relation]
  # @param columns [Array] Columns will be inferred if nil, but it's recommended to define it, otherwise
  # the columns might be unpredictable.
  # @param sortable_columns [Array] Sortable columns will also be inferred, but they will be used only if the column exists in
  # the column array, so it's fine to leave sortable_columns to be inferred automatically.
  # @param row_transform [Proc] Convert every row that will be printed using some process (Proc). This will be applied after it
  # has been paginated, so it will only be applied to a limited number of rows. It might be quick even if the query is N+1.
  def render_table(columns: nil, results:, sortable_columns: nil, row_transform: nil)
    sortable_columns = infer_sortable_columns_from_relation(results) if sortable_columns.nil?
    columns = infer_columns_from_relation(results) if columns.nil?
    columns_with_options = {}
    columns.each do |col|
      columns_with_options[col] = {
        sort: sortable_columns.include?(col)
      }
    end

    results = results.filter_by_table_params(table_params)
    total_count = results.total_count
    results = row_transform.is_a?(Proc) ? results.map { |row| row_transform.call(row) } : results.select(columns)

    # TODO: Instead of 'row_transform' (Proc), just build a JBuilder view.
    # Actually the Proc sounds too complex to understand for developers that may not be used to something like this.
    # However the problem is that this method 'render_table' helps to render all the necessary datatables
    # extra stuff (which would be a boiler plate).
    #
    # Maybe add some parameter to this method that tells it to render the associated jbuilder template.
    # But if I do that, then remove row_transform because it's too shit.

    render json: {
      columns: columns_with_options,
      data: results,
      total: total_count
    }
  end

  def render_datatables_with_row_partial(columns:, data:, row_partial:, sortable_columns: nil)
    sortable_columns = infer_sortable_columns_from_relation(data) if sortable_columns.nil?
    columns = infer_columns_from_relation(data) if columns.nil?
    columns_with_options = {}
    columns.each do |col|
      columns_with_options[col] = {
        sort: sortable_columns.include?(col)
      }
    end

    data = data.filter_by_table_params(table_params)
    @total_count = data.total_count
    render 'datatables/generic_datatables', locals: { columns: columns_with_options, data: data, row_partial: row_partial }
  end

  def infer_columns_from_relation(relation)
    relation.columns.map { |col| col.name.to_sym }
  end

  # If the parameter is a relation, then it will infer the columns that can be used for sorting.
  # Reminder: sortable columns are columns that have index(es).
  # @param relation [ActiveRecord_Relation]
  # @return [Array] Columns that can be used for sorting.
  def infer_sortable_columns_from_relation(relation)
    model = relation.model
    model.columns_with_index
  rescue
    raise "Cannot infer sortable columns (i.e. columns that have indexes) from object (#{relation.class}): #{relation}"
  end

  private

  def handle_params!
    param! :p,           Integer, default: 1, min: 1
    param! :per_page,    Integer, max: MAX_PAGE_SIZE, in: [10, 50, 100]
    param! :sort_by,     String, transform: proc { |s| s.underscore.to_sym }
    param! :sort_by_dir, String, in: %i[asc desc], transform: :to_sym
    param! :keyword,     String, default: ''
  end
end
