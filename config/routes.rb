Rails.application.routes.draw do
  
  namespace 'api' do
    namespace 'v1' do
      get '/users' => 'users#index'
      get '/users/:id' => 'users#show'
      put '/users/:id/update' => 'users#update'
      get '/users/:id/token' => 'users#token'
      get '/userid' => 'users#id'
      get '/login' => 'users#login'

      put 'comments/:id/vote' => 'comments#vote'
      put 'comments/:id/unvote' => 'comments#unvote'
      put '/comments/:id/update' => 'comments#update'
      get '/submissions/:id/comments' => 'comments#submission_comments'
      get '/user/:id/comments' => 'comments#threads'
      get '/comment/:id' => 'comments#comment'
      post '/submission/:id/comment' => 'comments#create'
      delete '/comments/:id/' => 'comments#destroy'

      post '/comment/:id/reply' => 'replies#create'
      post '/reply/:id/reply' => 'replies#create_reply'
      put 'replies/:id/vote' => 'replies#vote'
      put 'replies/:id/unvote' => 'replies#unvote'
      put '/replies/:id/update' => 'replies#update'
      get '/comments/:id/replies' => 'replies#comment_replies'
      get '/replies/:id/replies' => 'replies#replies_replies'
      get '/replies/:id' => 'replies#reply'
      delete '/replies/:id/' => 'replies#destroy'

      get '/submissions' => 'submissions#all'
      get '/submissions/url' => 'submissions#url'
      get '/submissions/ask' => 'submissions#ask'
      get '/submissions/:id/' => 'submissions#show'
      post '/submissions' => 'submissions#create'
      put '/submissions/:id/vote' => 'submissions#vote'
      put '/submissions/:id/unvote' => 'submissions#unvote'
      delete '/submissions/:id' => 'submissions#destroy'
    end
  end

  get 'sessions/create'

  get 'sessions/destroy'

  resources :submissions
  resources :users
  resources :comments
  resources :replies

  
  get 'newest' => 'submissions#newest'
  get 'ask' => 'submissions#ask'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'threads' => 'comments#threads'

  post 'submissions/:id/vote' => 'submissions#vote'
  post 'submissions/:id/unvote' => 'submissions#unvote'
  post 'comments/:id/vote' => 'comments#vote'
  post 'comments/:id/unvote' => 'comments#unvote'
  post 'replies/:id/vote' => 'replies#vote'
  post 'replies/:id/unvote' => 'replies#unvote'
  post 'repliesR' => 'replies#create_reply'

  get 'repliesR/:id/edit' => 'replies#edit_replies'

  get 'comments/:id/new_reply' => 'comments#new_reply'
  get 'replies/:id/new_reply' => 'replies#new_reply'
  get '/submissions/:id/comments' => 'comments#submission_comments'
  get '/comments/:id/replies' => 'replies#comment_replies'
    
  resources :sessions, only: [:create, :destroy]

  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end
