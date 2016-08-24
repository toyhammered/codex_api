Rails.application.routes.draw do
  post '/request' => 'check#receives_data'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
