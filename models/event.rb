# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :source, optional: true

  def self.sanitize_str(str)
    str
  end

  def self.from_fb_event(fb_event)
    event = find_or_initialize_by(uid: fb_event['id'])

    event.name = sanitize_str(fb_event['name'])
    event.content = sanitize_str(fb_event['description'])
    event.starts_at = fb_event['start_time']
    event.ends_at = fb_event['end_time']
    event.organiser = fb_event.dig('parent_group', 'name') || fb_event.dig('owner', 'name')
    event.location_name = sanitize_str fb_event.dig('place', 'name')

    location = fb_event.dig('place', 'location')

    if location
      event.location = sanitize_str(location.to_json)
      event.coordinates = "#{location['latitude']}, #{location['longitude']}"
    end

    event
  end

end
