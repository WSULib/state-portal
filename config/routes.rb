Rails.application.routes.draw do

  scope :admin do
    scope :solr, controller: 'solr_management' do
      get '/', action: 'index'
      post 'update'
      post 'reindex'
    end
  end

  mount Blacklight::Oembed::Engine, at: 'oembed'
  mount Riiif::Engine => '/images', as: 'riiif'
  # root to: 'spotlight/exhibits#index' # spotlight root path
  root to: "catalog#index" # blacklight root path
  mount Spotlight::Engine, at: 'spotlight'
  mount Blacklight::Engine => '/'
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

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
