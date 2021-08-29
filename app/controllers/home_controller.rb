class HomeController < ApplicationController
  def index
    render json: {
      message: 'API root'
    }
  end
end
