Rails.application.routes.draw do

  get '/projects', to: 'projects#index'
  post '/projects', to: 'projects#create'

  get '/projects/:project_id', to: 'projects#show'

  get '/projects/:project_id/views', to: 'views#index'
  post '/projects/:project_id/views', to: 'views#create'

  get '/projects/:project_id/views/:view_id', to: 'views#show'
  get '/projects/:project_id/views/:view_id/queries', to: 'queries#index'
  post '/projects/:project_id/views/:view_id/queries', to: 'queries#create'
  get '/projects/:project_id/views/:view_id/queries/:query_id', to: 'queries#show'
  put '/projects/:project_id/views/:view_id/queries/:query_id', to: 'queries#update'
  get '/projects/:project_id/views/:view_id/queries/:query_id/log', to: 'query_histories#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
