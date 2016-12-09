require 'sinatra'
require 'sinatra/json'

require './db/database'

get '/events' do
  json Event.all
end
