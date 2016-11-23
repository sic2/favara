require 'active_record'
require 'yaml'

db_config = YAML.load_file('database.yml')

ActiveRecord::Base.establish_connection(db_config)

class Source < ActiveRecord::Base
  has_many :posts
  has_many :events

  def self.from_fb_group fb_group
    group_uid = fb_group['id']
    group_name = fb_group['name']
    group_privacy = fb_group['privacy']
    group_icon = fb_group['icon']

    if exists?(uid: group_uid)
  		group = where(uid: group_uid).first
  		group.touch
    else
		  group = Source.new()

	    group.stype = 'group'
	    group.source = 'fb'
    end

    group.uid = group_uid
    group.name = group_name
    group.privacy = group_privacy
    group.icon_link = group_icon

    group
  end

  def self.from_fb_page fb_page
    page_uid = fb_page['id']
    page_name = fb_page['name']

    if exists?(uid: page_uid)
      page = where(uid: page_uid).first
      page.touch
    else
      page = Source.new()

      page.stype = 'page'
      page.source = 'fb'
    end

    page.uid = page_uid
    page.name = page_name

    page
  end

  def isOPEN
    privacy.eql? "OPEN"
  end

end


class Event < ActiveRecord::Base
  belongs_to :source, optional: true

  scope :future, -> { where "ends_at >= ?", Time.zone.now.beginning_of_day }
  scope :past, -> { where "ends_at < ?", Time.zone.now.beginning_of_day }
  scope :only_with_coordinates, -> { where "coordinates IS NOT NULL" }

  def self.name_like query
    ilike :name, query
  end

  def self.from_fb_event fb_event

    uid = fb_event['id']
    name = Sanitize.encode(fb_event['name'])
    content = if fb_event['description'] then Sanitize.encode(fb_event['description']) else nil end
    starts_at = fb_event['start_time']
    ends_at = fb_event['end_time']

    if Event.exists?(uid: uid)
      event = Event.where(uid: uid).first
    else
      event = Event.new()
    end

    event.uid = uid
    event.name = name
    event.content = content
    event.starts_at = starts_at
    event.ends_at = ends_at

    event.location_name = fb_event['place'] ? Sanitize.encode(fb_event['place']['name']) : nil
    event.location = fb_event['place'] ? Sanitize.encode(fb_event['place']['location'].to_json) : nil

    if fb_event['place'] && fb_event['place']['location']
      event.coordinates = fb_event['place']['location']['latitude'].to_s + ', ' + fb_event['place']['location']['longitude'].to_s
    end

    if fb_event['parent_group']
      event.organiser = fb_event['parent_group']['name']
    else
      event.organiser = fb_event['owner']['name']
    end

    event
  end

  def current?
    ends_at > Time.zone.now.beginning_of_day and starts_at < Time.zone.now.end_of_day
  end

  def external_link
    'https://www.facebook.com/events/' + uid
  end

  def coord
    if coordinates
      coordinates.gsub(/\s+/, "")
    else
      nil
    end
  end


  def as_json(options={})
    super(only: [:name, :starts_at, :ends_at, :content, :location, :location_name, :coordinates])
  end

end


class Post < ActiveRecord::Base
  belongs_to :source, optional: true

  Job_tags = ['#lavoro', '#jobs', '#job', '#cercosocio', '[job]', '[jobs]']

  def self.from_fb_post feed_post
    post = Post.new()
    post.uid = feed_post['id']
    post.content = feed_post['message']
    post.author_name = feed_post['from']['name']
    post.author_uid = feed_post['from']['id']
    post.created_at = feed_post['created_time']
    post.updated_at = feed_post['updated_time']
    post.post_type = feed_post['type']
    post.caption = feed_post['caption']
    post.description = feed_post['description']
    post.name = feed_post['name']

    if feed_post['link'] != nil
      post.link = feed_post['link']
    end

    if feed_post['picture'] != nil
      post.picture = feed_post['picture']
    end

    if post.content != nil
      jobs = Job_tags.any? { |word| post.content.downcase.include?(word) }
      if jobs
        post.tags = 'job' # Improve?
      end
    end

    post.likes_count = feed_post['likes']['summary']['total_count']
    post.comments_count = feed_post['comments']['summary']['total_count']

    if feed_post['shares'] != nil
      post.shares_count = feed_post['shares']['count']
    else
      post.shares_count = 0
    end

    # Show post by default
    post.show = true

    post
  end

  def self.only_jobs
    where(:tags => 'job')
  end

  def facebook_link
    if post_type == "event"
      nil
    else
      'https://www.facebook.com/' + uid
    end
  end

  def alt
    if name?
      name
    else
      content[0..40]
    end
  end

  def as_json(options={})
    super(only: [:name, :content, :link, :author_name, :post_type, :created_at])
  end

end
