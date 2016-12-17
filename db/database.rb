require 'active_record'
require 'yaml'

env_config = {
  adapter: ENV['FAVARA_DB_ADAPTER'],
  encoding: ENV['FAVARA_DB_ENCODING'],
  pool: ENV['FAVARA_DB_POOL'],
  username: ENV['FAVARA_DB_USERNAME'],
  password: ENV['FAVARA_DB_PASSWORD'],
  host: ENV['FAVARA_DB_HOST'],
  database: ENV['FAVARA_DB_DATABASE']
}.delete_if { |k, v| v.nil? }

db_config = YAML.load_file('database.yml')
db_config.merge!(env_config)

ActiveRecord::Base.establish_connection(db_config)

require './models/application_record'
require './models/source'
require './models/event'
require './models/post'
