# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  mount Decidim::Core::Engine => "/"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #
end

# Add a simple menu in the admin part
Decidim::Admin::Engine.routes.draw do
  resources :getxo, only: [:index], as: :admin_getxo do
    collection do
      get :streets
      post :check
      get :sync

      resources :zones, except: :show, as: "admin_getxo_zones"
    end
  end
end
