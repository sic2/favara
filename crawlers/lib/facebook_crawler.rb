# frozen_string_literal: true
require 'koala'
require 'json'
require 'logger'

class FacebookCrawler
  Feed_fields = ['id', 'message', 'from', 'type',
                 'picture', 'link', 'created_time',
                 'updated_time', 'name', 'caption', 'description',
                 'shares', 'likes.summary(true)', 'comments.summary(true)'].freeze

  Event_fields = %w(id name description
                    start_time end_time updated_time
                    place parent_group owner).freeze

  Group_fields = %w(id name privacy icon).freeze

  Page_fields = %w(id name).freeze
  DEFAULT_PAGE_SIZE = 50

  def get_token(app_id, app_secret)
    raise 'either a token or app_id and app_secret should be defined' unless app_id and app_secret
    oauth = Koala::Facebook::OAuth.new(app_id, app_secret, '')
    oauth.get_app_access_token
  end

  # takes an options hash
  # :token => the facebook app token to use
  # :app_id, :app_secret => the app id and secret to use to get the token, if token is not given
  # :page_size => how many results to get with each call, defaults to 50
  # :logger => the logger to use (defaults to stderr)
  def initialize(options = {})
    @logger = options[:logger] || Logger.new(STDERR)
    Koala::Utils.logger = @logger
  
    token = options[:token] || get_token(options[:app_id],options[:app_secret])
    @graph = Koala::Facebook::API.new(token)
    @page_size = options[:page_size] || DEFAULT_PAGE_SIZE
  end

  def group_raw_feed(group_id, limit)
    options = { limit: limit, fields: Feed_fields }
    @graph.get_connection(group_id, 'feed', options)
  end

  # unused
  def group_members(group_id, limit)
    options = { limit: limit }
    @graph.get_connection(group_id, 'members', options)
  end

  def page_events(page_id)
    options = { fields: Event_fields }
    @logger.info "downloading events from page: #{page_id}"
    events = @graph.get_connection(page_id, 'events', options)
    @logger.info "downloaded #{events.size} events"
    events
  end

  # gets and processes 'limit' elements from a group with a given group_id
  # returns an enumerator with the resulting elements
  def group_feed(group_id, limit)
    Enumerator.new do |y|
      processed = 0
      current_page = group_raw_feed(group_id, @page_size)

      until current_page.empty? || (processed >= limit)
        current_page.each do |element|
          y << element
          processed = processed + 1
        end
        current_page = current_page.next_page
      end
    end
  end

  def post?(element)
    %w(status link photo event).include? element['type']
  end

  def event?(element)
    element['type'] == 'event' 
  end

  def event_info_from_feed_element(element)
    event_id = element['link'][/events\/(.?)*\//][7..-2]
    event_info(event_id)
  end

  def group_info(group_id)
    @graph.get_object(group_id, fields: Group_fields)
  end

  def page_info(page_id)
    @graph.get_object(page_id, fields: Page_fields)
  end

  # Get info about an event
  def event_info(event_id)
    @graph.get_object(event_id, fields: Event_fields)
  end

end
