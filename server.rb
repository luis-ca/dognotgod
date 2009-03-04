require 'rubygems'
require 'sinatra'
# require 'ruby-prof' 

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
  require 'file_system'
  require 'load'
  require 'disk'
  require 'memory'
end
 
error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join("\n")
  "<pre>" + e + "<br /><br />" + e.backtrace.join("\n")
  
  # "Application error"
end
 
helpers do
  
  def get_host_or_create_if_not_exist(hostname)
    host = DB[:hosts].filter(:hostname => hostname).first

    unless host
      DB[:hosts] << {:hostname => hostname}
      host = DB[:hosts].filter(:hostname => hostname).first
    end
    host
  end
  
  def get_fs_or_create_if_not_exist(host_id, fs_name, mounted_on)
    fs = DB[:file_systems].filter(:name => fs_name, :mounted_on => mounted_on).first

    unless fs
      DB[:file_systems] << {:name => fs_name, :mounted_on => mounted_on, :host_id => host_id}
      fs = DB[:file_systems].filter(:name => fs_name, :mounted_on => mounted_on).first
    end
    fs
  end
  
end

get '/stylesheets/style.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end

get "/" do
  # result = RubyProf.profile do

  @hosts = Host.order(:hostname).all

  @end_now = Time.now.utc.to_fifteen_minute_grain_format
  @start_24h_ago = @end_now - (60*60*24)
  @start_6h_ago = @end_now - (60*60*6)
  
  haml :main
# end
  # Print a graph profile to text
  # printer = RubyProf::GraphPrinter.new(result)
  # printer.print(File.new("tmp/profile.log",  "w"), 0)
end 

post "/load_stats" do

  begin
    host = get_host_or_create_if_not_exist(params[:hostname])
    load_stats = Load.new({:load_5_min => params[:load_5_min], :load_10_min => params[:load_10_min], :load_15_min => params[:load_15_min], :host_id => host[:id]})
    load_stats.save
    status(201)
  rescue
    status(500)
  end
end

post "/mem_stats" do
  
  begin
    host = get_host_or_create_if_not_exist(params[:hostname])
    mem_stats = Memory.new({:host_id => host[:id], :mem_available => params[:mem_available], :mem_used => params[:mem_used], :swap_available => params[:swap_available], :swap_used => params[:swap_used]})
    mem_stats.save
    status(201)
  rescue
    status(500)
  end
end

post "/file_system_stats" do
  
  begin
    host = get_host_or_create_if_not_exist(params[:hostname])
    fs   = get_fs_or_create_if_not_exist(host[:id], params[:file_system_name], params[:mounted_on])
    
    disk_stats = Disk.new({:file_system_id => fs[:id], :used => params[:used], :available => params[:available]})
    disk_stats.save
    status(201)
  rescue
    status(500)
  end
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
