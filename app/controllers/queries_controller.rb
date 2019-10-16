class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :update, :destroy]

  # GET /queries
  def index
    view = View.where(project_id: params[:project_id], id: params[:view_id]).first
    @queries = view.queries

    render json: @queries
  end

  # GET /queries/1
  def show
    render json: @query
  end

  # POST /queries
  def create

    view = View.where(id: params[:view_id], project_id: params[:project_id]).first
    @query = view.queries.create query_params

    if @query
      render json: @query, status: :created# TODO, location: @query
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /queries/1
  def update

    content_before_update = @query.code || ""
    comment = params[:comment] || ""

    if @query.update(query_params)

      @query.query_histories << QueryHistory.new(comment: comment, previous_content: content_before_update)

      render json: @query
    else
      render json: @query.errors, status: :unprocessable_entity
    end
  end

  # DELETE /queries/1
  def destroy
    @query.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_query
      @query = Query.find(params[:query_id])
    end

    # Only allow a trusted parameter "white list" through.
    def query_params
      params.require(:query).permit(:code)
    end
end
