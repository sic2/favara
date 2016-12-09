# frozen_string_literal: true
require 'clockwork'

def night?
  !((5...23).cover? Time.now.hour)
end

module Clockwork
  handler do |job, _time|
    if job == 'crawl'
      if night?
        system 'rake crawl[true]'
      else
        system 'rake crawl[false]'
      end
    end
  end

  every(15.minutes, 'crawl')
end
