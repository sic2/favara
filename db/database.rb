require 'active_record'
require 'yaml'

db_config = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(db_config)

require './models/application_record'
require './models/source'
require './models/event'
require './models/post'
