require 'rubygems'
require 'spec'
require 'sequel'

Sequel.sqlite

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../app/models')

module CustomTimeMatcher
  class TimeMatcher
    def initialize(expected)
      @expected = expected
    end
    def matches?(target)
      @target = target
      @target.eql?(@expected)
    end
    def failure_message
      "expected #{@expected} but got #{@target.inspect}"
    end
    def negative_failure_message
      "expected #{@expected} but didn't get #{@target.inspect}"
    end
  end

  def equal_time_at(expected)
    TimeMatcher.new(expected)
  end
end

Spec::Runner.configure do |config|
  config.include(CustomTimeMatcher)
end