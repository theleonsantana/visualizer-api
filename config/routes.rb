Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do

      resources :users
    
    end
  end

  #Auth 
  namespace :api do
    namespace :v1 do
      
      get '/login', to: "auth#spotify_request"
      get '/user', to: "users#create"

    end
  end
  
  resources :users

end
