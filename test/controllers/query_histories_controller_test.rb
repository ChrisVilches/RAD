require 'test_helper'

class QueryHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @query_history = query_histories(:one)
  end

  test "should get index" do
    get query_histories_url, as: :json
    assert_response :success
  end

  test "should create query_history" do
    assert_difference('QueryHistory.count') do
      post query_histories_url, params: { query_history: { comment: @query_history.comment } }, as: :json
    end

    assert_response 201
  end

  test "should show query_history" do
    get query_history_url(@query_history), as: :json
    assert_response :success
  end

  test "should update query_history" do
    patch query_history_url(@query_history), params: { query_history: { comment: @query_history.comment } }, as: :json
    assert_response 200
  end

  test "should destroy query_history" do
    assert_difference('QueryHistory.count', -1) do
      delete query_history_url(@query_history), as: :json
    end

    assert_response 204
  end
end
