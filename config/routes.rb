Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  root to: "home#index"

  get '/companies/:company_url/projects', to: 'projects#index'
  post '/companies/:company_url/projects', to: 'projects#create'

  get '/companies/:company_url/project/:project_id', to: 'projects#show'
  get '/companies/:company_url/project/:project_id/connections', to: 'connections#index'
  post '/companies/:company_url/project/:project_id/connections', to: 'connections#create'
  post '/companies/:company_url/project/:project_id/connection/:connection_id/add_user', to: 'connections#add_user'

  get '/companies/:company_url/project/:project_id/views', to: 'views#index'
  post '/companies/:company_url/project/:project_id/views', to: 'views#create'

  get '/companies/:company_url/project/:project_id/view/:view_id', to: 'views#show_without_details'
  get '/companies/:company_url/project/:project_id/view/:view_id/details', to: 'views#show_with_details'
  put '/companies/:company_url/project/:project_id/view/:view_id', to: 'views#update'

  get '/companies/:company_url/project/:project_id/view/:view_id/queries', to: 'queries#index'
  post '/companies/:company_url/project/:project_id/view/:view_id/queries', to: 'queries#create'
  get '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id', to: 'queries#show'
  put '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id', to: 'queries#update'
  post '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id/add_connection', to: 'queries#add_connection'
  delete '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id/remove_connection', to: 'queries#remove_connection'
  delete '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id', to: 'queries#destroy'
  get '/companies/:company_url/project/:project_id/view/:view_id/query/:query_id/log', to: 'query_histories#index'

  post '/companies/:company_url/query/:query_id/execute', to: 'queries#execute'

  get '/companies/:company_url', to: 'companies#show'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
