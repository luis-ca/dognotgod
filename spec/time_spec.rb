require File.dirname(__FILE__) + '/base'
require 'server'

describe Time do
	before do
	end
  
  it "should return a Time object rounded up to the 5th minute" do
    time = Time.parse("2009-01-01 15:03:56")
    time.to_five_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:05:00"))
  end
  
  it "should return a Time object rounded up to the 10th minute" do
    time = Time.parse("2009-01-01 15:03:56")
    time.to_ten_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:10:00"))
  end
  
  it "should return a Time object rounded up to the 15th minute" do
    time = Time.parse("2009-01-01 15:03:56")
    time.to_fifteen_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:15:00"))
    
    time = Time.parse("2009-01-01 15:14:59")
    time.to_fifteen_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:15:00"))
    
    time = Time.parse("2009-01-01 15:00:00")
    time.to_fifteen_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:15:00"))
    
    time = Time.parse("2009-01-01 15:15:00")
    time.to_fifteen_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:30:00"))
    
    time = Time.parse("2009-01-01 15:48:33")
    time.to_fifteen_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
  end
  
  it "should return a Time object rounded up to the 30th minute" do
    time = Time.parse("2009-01-01 15:03:56")
    time.to_thirty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:30:00"))
    
    time = Time.parse("2009-01-01 15:14:59")
    time.to_thirty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:30:00"))
    
    time = Time.parse("2009-01-01 15:00:00")
    time.to_thirty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 15:30:00"))
    
    time = Time.parse("2009-01-01 15:30:00")
    time.to_thirty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 15:48:33")
    time.to_thirty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
  end
  
  it "should return a Time object rounded up to the 60th minute" do
    time = Time.parse("2009-01-01 15:03:56")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 15:14:59")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 15:00:00")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 15:30:00")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 15:52:55")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 16:00:00"))
    
    time = Time.parse("2009-01-01 16:00:00")
    time.to_sixty_minute_grain_format.should equal_time_at(Time.parse("2009-01-01 17:00:00"))
  end
end
