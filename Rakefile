task :environment do
  require './db/database'
end

load './crawlers/facebook.rake'

task :favara, [:complete] => [:crawl_fb] do
end

task :create_tables do
  require 'db/migrations/001_init.rb'
  AddCrawlerTables.new.migrate(:up)
end

task :destroy_tables do
  require 'db/migrations/001_init.rb'
  AddCrawlerTables.new.migrate(:down)
end
