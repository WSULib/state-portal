Rails.application.routes.draw do

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'
  root to: 'spotlight/home_pages#show', exhibit_id: 'default' # spotlight root path
  # root to: "catalog#index" # blacklight root path
  mount Spotlight::Engine, at: 'exhibits'
  mount Blacklight::Engine => '/'
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  # devise_for :users
  # concern :exportable, Blacklight::Routes::Exportable.new

  devise_for :users, skip: [:registrations]
  concern :exportable, Blacklight::Routes::Exportable.new
  as :user do
    get "/users/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    get "/sign_up" => "devise/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
