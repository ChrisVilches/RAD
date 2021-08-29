Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  mount ActionCable.server => '/cable'

  root to: 'home#index'

  scope 'companies' do
    get '/', to: 'companies#index'

    scope '/:company_url' do
      # TODO: Using resources
      get '/project/:project_id', to: 'projects#show'
      scope '/projects' do
        get '/', to: 'projects#index'
        post '/', to: 'projects#create'
      end

      get '/', to: 'companies#show'
      get '/view/:view_id', to: 'views#show_without_details'
      get '/view/:view_id/details', to: 'views#show_with_details'
      put '/view/:view_id', to: 'views#update'

      delete '/connection/:connection_id', to: 'connections#destroy'
      delete '/connection/:connection_id/user/:user_id', to: 'connections#remove_user'
      post '/connection/:connection_id/user/:user_id', to: 'connections#add_user'

      get '/view/:view_id/queries', to: 'queries#index'
      post '/view/:view_id/queries', to: 'queries#create'
      get '/query/:query_id', to: 'queries#show'
      put '/query/:query_id', to: 'queries#update'
      delete '/query/:query_id', to: 'queries#destroy'

      post '/query/:query_id/add_connection', to: 'queries#add_connection'
      delete '/query/:query_id/remove_connection', to: 'queries#remove_connection'
      get '/connection/:connection_id/users', to: 'users#connection_users'
      get '/query/:query_id/connections', to: 'connections#query_useable'

      scope '/project/:project_id' do
        #get '/', to: 'projects#show'
        put '/', to: 'projects#update'

        get '/summary', to: 'projects#summary'
        put '/favorite', to: 'projects#favorite'
        put '/unfavorite', to: 'projects#unfavorite'
        get '/activity', to: 'query_executions#index'
        get '/users', to: 'users#project_users'

        delete '/', to: 'projects#destroy'
        get '/connections', to: 'connections#index'
        post '/connections', to: 'connections#create'
        put '/connection/:connection_id', to: 'connections#update'

        get '/views', to: 'views#index'
        post '/views', to: 'views#create'

        put '/assign_permission_batch', to: 'projects#assign_permission_batch'
        put '/assign_participation_batch', to: 'projects#assign_participation_batch'

        get '/view/:view_id/query/:query_id/log', to: 'query_histories#index'
      end

      get '/query_execution/:query_execution_id', to: 'query_executions#show'
      get '/query_execution/:query_execution_id/result', to: 'query_executions#result'
      post '/query/:query_id/execute', to: 'queries#execute'
    end
  end
end
