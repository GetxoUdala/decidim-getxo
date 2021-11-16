# frozen_string_literal: true

Rails.application.routes.draw do
  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: "/delayed_job"
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

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

      resources :zones, as: "admin_getxo_zones"
    end
  end
end
