# frozen_string_literal: true
class Post < ApplicationRecord
  belongs_to :source, optional: true

  Job_tags = ['#lavoro', '#jobs', '#job', '#cercosocio', '[job]', '[jobs]', '#offertadilavoro'].freeze

  def self.from_fb_post(feed_post)
    post = find_or_initialize_by(uid: feed_post['id'])

    post.content = feed_post['message']
    post.tags = tags_from_content(post.content).join(',')
    post.author_name = feed_post.dig('from', 'name')
    post.author_uid = feed_post.dig('from', 'id')
    post.created_at = feed_post['created_time']
    post.updated_at = feed_post['updated_time']
    post.post_type = feed_post['type']
    post.caption = feed_post['caption']
    post.description = feed_post['description']
    post.name = feed_post['name']
    post.link = feed_post['link'] # may be nil
    post.picture = feed_post['picture'] # may be nil
    post.likes_count = feed_post.dig('likes', 'summary', 'total_count') || 0
    post.comments_count = feed_post.dig('comments', 'summary', 'total_count') || 0
    post.shares_count = feed_post.dig('shares', 'count') || 0
    post.show = post.show == false ? false : true

    post
  end

  def self.tags_from_content(content)
    return [] unless content
    tags = []
    tags << 'job' if Job_tags.any? { |word| content.downcase.include?(word) }
    tags
  end
end
