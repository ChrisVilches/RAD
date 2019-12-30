class QueryHistoriesController < AuthenticatedController
  before_action :set_query_history, only: [:show, :update, :destroy]

  # GET /query_histories
  def index
    @query_histories = QueryHistory.where query_id: params[:query_id]

    render json: @query_histories
  end
=begin
  # GET /query_histories/1
  def show
    render json: @query_history
  end

  # POST /query_histories
  def create
    @query_history = QueryHistory.new(query_history_params)

    if @query_history.save
      render json: @query_history, status: :created, location: @query_history
    else
      render json: @query_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /query_histories/1
  def update
    if @query_history.update(query_history_params)
      render json: @query_history
    else
      render json: @query_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /query_histories/1
  def destroy
    @query_history.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query_history
      @query_history = QueryHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def query_history_params
      params.require(:query_history).permit(:comment)
    end
=end
end
