Rails.application.routes.draw do

  get '/projects', to: 'projects#index'
  post '/projects', to: 'projects#create'

  get '/project/:project_id', to: 'projects#show'

  get '/project/:project_id/views', to: 'views#index'
  post '/project/:project_id/views', to: 'views#create'

  get '/project/:project_id/view/:view_id', to: 'views#show'
  get '/project/:project_id/view/:view_id/queries', to: 'queries#index'
  post '/project/:project_id/view/:view_id/queries', to: 'queries#create'
  get '/project/:project_id/view/:view_id/queries/:query_id', to: 'queries#show'
  put '/project/:project_id/view/:view_id/queries/:query_id', to: 'queries#update'
  get '/project/:project_id/view/:view_id/queries/:query_id/log', to: 'query_histories#index'

  post '/query/:query_id/execute', to: 'queries#execute'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
