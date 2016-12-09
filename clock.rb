# frozen_string_literal: true
require 'clockwork'

def night?
  !((5...23).cover? Time.now.hour)
end

module Clockwork
  handler do |job, _time|
    if job == 'favara'
      if night?
        system 'rake favara[true]'
      else
        system 'rake favara[false]'
      end
    end
  end

  every(15.minutes, 'favara')
end
