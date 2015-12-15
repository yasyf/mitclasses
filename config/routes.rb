Rails.application.routes.draw do
  namespace :api, constraints: { format: :json } do
    namespace :v1 do
      constraints id: /[^\/]+/ do
        resources :classes, only: :show
        resources :semesters, only: :index do
          resources :classes, only: :show
        end
      end
    end
  end
end
