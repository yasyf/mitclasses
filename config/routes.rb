require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :students, only: :show do
    resources :schedule, only: :index
    resources :feedbacks, only: [:index, :update, :destroy]
  end
  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      constraints id: /[^\/]+/ do
        resources :schedules, only: [:show, :index]
        resources :classes, only: [:show, :index] do
          get :feedback, on: :collection
        end
        resources :semesters, only: :index do
          resources :classes, only: :show
        end
      end
    end
  end
end
