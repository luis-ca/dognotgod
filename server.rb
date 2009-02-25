require 'rubygems'
require 'sinatra'
 
configure do
  DB_DIR = "#{ENV['HOME']}/.dognotgod"
  
  $LOAD_PATH.unshift File.dirname(__FILE__) + '/app/models'
  require 'sequel'
  require 'logger'
  
  Dir.mkdir(DB_DIR) unless File.exists?(DB_DIR)
  DB = Sequel.connect("sqlite://#{DB_DIR}/dog.db")
  DB.loggers << Logger.new($stdout)
 
  # require 'ostruct'
  require 'host'
  require 'load'
end
 
error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join("\n")
  "<pre>" + e + "<br /><br />" + e.backtrace.join("\n")
  
  # "Application error"
end
 
helpers do
  def admin?
    # request.cookies[Blog.admin_cookie_key] == Blog.admin_cookie_value
  end
 
  def auth
    stop [ 401, 'Not authorized' ] unless admin?
  end
end
 
get "/" do
  @hosts = Host.order(:hostname).all

  @end_now = Time.now.to_fifteen_minute_grain_format
  @start_24h_ago = @end_now - (60*60*24)
  @start_6h_ago = @end_now - (60*60*6)
  
  haml :main
end 

get "/hosts/:id/loads.xml" do
  @host = Host[params[:id]]
  
  @end_time = Time.now.to_five_minute_grain_format # Round to zero seconds on the minute
  @start_time = @end_time - (60*60*24)
  @time_range = (@start_time..@end_time)
  
  @loads = @host.loads2(@start_time, @end_time)
  
  content_type 'application/xml', :charset => 'utf-8'
  haml :loads_xml, :layout => false
end

post "/loads" do
  host = DB[:hosts].filter(:hostname => params[:hostname]).first
  
  # create an entry for a new host if it doesn't exist
  unless host
    DB[:hosts] << {:hostname => params[:hostname]}
    host = DB[:hosts].filter(:hostname => params[:hostname]).first
  end
  
  @now = Time.now
  
  load = Load.new({:load_5_min => params[:load_5_min], :load_10_min => params[:load_10_min], :load_15_min => params[:load_15_min], :host_id => host[:id], :created_at => @now})
  if load.save
    status(201)
    # response['Location'] = ""
  else
    status(500)
  end
end

get '/stylesheets/style.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end


class Time
  
  # Rounds up to the 5 min intervals
  def to_five_minute_grain_format
    offset = (5-(self.min.to_i%5)) * 60
    Time.parse((self + offset).strftime("%Y-%m-%d %H:%M"))
  end
  
  # Rounds up to the 10 min intervals
  def to_ten_minute_grain_format
    offset = (10-(self.min.to_i%10)) * 60
    Time.parse((self + offset).strftime("%Y-%m-%d %H:%M"))
  end
  
  # Rounds up to the 15 min intervals
  def to_fifteen_minute_grain_format
    offset = (15-(self.min.to_i%15)) * 60
    Time.parse((self + offset).strftime("%Y-%m-%d %H:%M"))
  end
  
  # Rounds up to the 30 min intervals
  def to_thirty_minute_grain_format
    offset = (30-(self.min.to_i%30)) * 60
    Time.parse((self + offset).strftime("%Y-%m-%d %H:%M"))
  end
  
  # Rounds up to the 60 min intervals
  def to_sixty_minute_grain_format
    offset = (60-(self.min.to_i%60)) * 60
    Time.parse((self + offset).strftime("%Y-%m-%d %H:%M"))
  end

  def to_minute_format
    self.strftime("%Y-%m-%d %H:%M")
  end
  
  def to_sql_format
    self.strftime("%Y-%m-%dT%H:%M")
  end
end
