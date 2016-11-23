require 'sinatra'
require "sinatra/json"

require './database'

get '/events' do
  json Event.all
end
