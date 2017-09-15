# frozen_string_literal: true
require './crawlers/lib/facebook_crawler'
require 'yaml'
require 'date'

config = YAML.load_file('config.yml')

FB_groups_to_track = config['fb']['groups']
FB_pages_to_track = config['fb']['pages']

desc 'Crawls events and posts from the given set of pages and insert the result into the database'
task :crawl_fb, [:complete] => :environment do |_t, args|
  args.with_defaults(complete: false)

  complete_crawling = args[:complete]
  feed_limit = complete_crawling ? 2000 : 50

  Rails.logger.level = Logger::DEBUG if defined? Rails

  unless ENV['ISAMUNI_APP_ID'] && ENV['ISAMUNI_APP_SECRET']
    raise 'Application id and/or secret are not specified in the environment'
  end

  log 'Crawler started, initializing'
  time_started = Time.now

  fb_crawling ENV['ISAMUNI_APP_ID'], ENV['ISAMUNI_APP_SECRET'], feed_limit

  log "Crawling finished in #{Time.now - time_started}s :)"
end

def fb_crawling(app_id, app_secret, feed_limit)
  crawler = FacebookCrawler.new(app_id: app_id, app_secret: app_secret)

  # Insert sources into DB
  log 'crawling info about groups'
  FB_groups_to_track.each do |group|
    group_data = crawler.group_info(group['id'])
    Source.from_fb_group(group_data).save
  end

  log 'crawling info about pages'
  FB_pages_to_track.each do |page|
    page_data = crawler.page_info(page['id'])
    Source.from_fb_page(page_data).save
  end

  log 'crawling group feed'
  Source.where(stype: 'group').each do |source|
    next unless source.isOPEN
    
    log "downloading feed for group: #{source.name}"

    n_posts = 0
    n_events = 0

    feed = crawler.group_feed(source.uid, feed_limit)

    feed.each do |element|
      if crawler.post? element
        post = Post.from_fb_post(element)
        post.source = source
        post.save!
        n_posts = n_posts + 1
      end

      if crawler.event? element
        einfo = crawler.event_info_from_feed_element(element)
        e = Event.from_fb_event(einfo)
        e.source = source
        e.save!
        n_events = n_events + 1
      end
    end

    log "group #{source.name}: inserted/updated #{n_posts} posts, #{n_events} events"
  end

  log 'crawling pages feed'
  Source.where(stype: 'page').each do |source|
    page_events = crawler.page_events(source.uid)
    n_events = 0
    
    if crawler.event? element
      e = Event.from_fb_event(element)
      e.source = source
      e.save!
      n_events = n_events + 1
    end

    log "page #{source.name}: inserted/updated #{n_events} events"    
  end
end

def log(message)
  puts "[#{Time.now.strftime '%d/%m/%Y %H:%M:%S:%L'}] #{message}"
end
