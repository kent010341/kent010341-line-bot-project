Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/kent010341/eat', to: 'kent010341#eat'
  get '/kent010341/request_headers', to: 'kent010341#request_headers'
  get '/kent010341/request_body', to: 'kent010341#request_body'
  get '/kent010341/response_headers', to: 'kent010341#response_headers'
  get '/kent010341/response_body', to: 'kent010341#show_response_body'
  get '/kent010341/sent_request', to: 'kent010341#sent_request'
end
