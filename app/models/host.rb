class Host < Sequel::Model

  one_to_many :loads
  one_to_many :file_systems
  one_to_many :memories
  
	unless table_exists?
		set_schema do
			primary_key :id
		  text :hostname
			timestamp :created_at
		end
		create_table
	end
	
	# Timestamp of last entry in 'loads' table for this host
	def last_contacted_on
	  self.loads.last.created_at if self.loads.last
  end
  
  # Seconds to timestamp of last entry in 'loads' table for this host
  def distance_to_last_heartbeat_in_seconds
    (Time.now - self.loads.last.created_at) if self.loads.last
  end

  def total_disk_space_in_Gb
    @total = 0
    self.file_systems.each do |fs|
      @total += fs.size_in_Gb
    end
    
    @total
  end

  def available_disk_space_in_Gb
    @available = 0
    self.file_systems.each do |fs|
      @available += fs.available_in_Gb
    end
    
    @available
  end
  
  def available_disk_space_percent
    @total = 0
    @available = 0
    
    self.file_systems.each do |fs|
      @total += fs.size_in_Gb
      @available += fs.available_in_Gb
    end
    
    @available.to_f / @total * 100 if @total  > 0
  end

  def total_memory_in_Mb
	  last_entry = DB[:memories].filter(:host_id => self.id).reverse_order(:created_at).last
	  if last_entry
      (last_entry[:mem_available] + last_entry[:mem_used]) / 1024
    else
      0
    end
  end

  def available_memory_in_Mb
	  last_entry = DB[:memories].filter(:host_id => self.id).reverse_order(:created_at).last
	  if last_entry
      last_entry[:mem_available] / 1024
    else
      0
    end
  end
  
  def used_memory_in_Mb
	  last_entry = DB[:memories].filter(:host_id => self.id).reverse_order(:created_at).last
	  if last_entry
      last_entry[:mem_used] / 1024
    else
      0
    end
  end
  
  def total_swap_in_Mb
  end
  
  def available_swap_in_Mb
  end
  
  def used_swap_in_Mb
  end

  def loads_5_min_grain(start_time, end_time)
    load = DB.fetch("SELECT ROUND(AVG(load_5_min),1) AS load_5_min, ROUND(AVG(load_10_min),1) AS load_10_min, ROUND(AVG(load_15_min),1) AS load_15_min, grain_5_min FROM loads WHERE host_id = #{self.id} AND grain_5_min >= '#{start_time.to_five_minute_grain_format.to_sql_format}' AND grain_5_min <= '#{end_time.to_five_minute_grain_format.to_sql_format}' GROUP BY grain_5_min;").all
    
    time_range = (start_time..end_time)
    
    series = []
    series[0] = []
    series[1] = []
    series[2] = []
    series[3] = []
    time_range.step(300) do |five|
      series[0] << five.to_minute_format
      if load.size > 0 and load[0][:grain_5_min].to_minute_format == five.to_minute_format
        load_for_this_dim = load.shift
        series[1] << load_for_this_dim[:load_5_min]
        series[2] << load_for_this_dim[:load_10_min]
        series[3] << load_for_this_dim[:load_15_min]
      else
        series[1] << -1
        series[2] << -1
        series[3] << -1
      end
    end
    
    series
  end
  
  # 
  # Returns the load for this host in the following format
  #
  # series[0] will contain the time series data. This method will return the data in 15 min intervals.
  # series[1] will contain the 5 min load averages
  # series[2] will contain the 10 min load averages
  # series[3] will contain the 15 min load averages
  #
  # If not data exists for a particular time period, then the value is -1
  #
  def loads_15_min_grain(start_time, end_time)
    load = DB.fetch("SELECT ROUND(AVG(load_5_min),1) AS load_5_min, ROUND(AVG(load_10_min),1) AS load_10_min, ROUND(AVG(load_15_min),1) AS load_15_min, grain_15_min FROM loads WHERE host_id = #{self.id} AND grain_15_min >= '#{start_time.to_fifteen_minute_grain_format.to_sql_format}' AND grain_15_min <= '#{end_time.to_fifteen_minute_grain_format.to_sql_format}' GROUP BY grain_15_min;").all
    
    time_range = (start_time..end_time)
    
    series = []
    series[0] = []
    series[1] = []
    series[2] = []
    series[3] = []
    i = 0
    time_range.step(900) do |fifteen|
      series[0] << fifteen.to_minute_format
      if load.size > 0 and load[0][:grain_15_min].to_minute_format == fifteen.to_minute_format
        load_for_this_dim = load.shift
        series[1] << load_for_this_dim[:load_5_min]
        series[2] << load_for_this_dim[:load_10_min]
        series[3] << load_for_this_dim[:load_15_min]
      else
        series[1] << -1
        series[2] << -1
        series[3] << -1
      end
    end
    
    series
  end
  

  def mems_15_min_grain(start_time, end_time)
    data = DB.fetch("SELECT ROUND(AVG(mem_available)/1024,0) AS mem_available, ROUND(AVG(mem_used)/1024,0) AS mem_used, ROUND(AVG(swap_available)/1024,0) AS swap_available, ROUND(AVG(swap_used)/1024, 0) AS swap_used, grain_15_min FROM memories WHERE host_id = #{self.id} AND grain_15_min >= '#{start_time.to_fifteen_minute_grain_format.to_sql_format}' AND grain_15_min <= '#{end_time.to_fifteen_minute_grain_format.to_sql_format}' GROUP BY grain_15_min;").all
    
    time_range = (start_time..end_time)
    
    series = []
    series[0] = []
    series[1] = []
    series[2] = []
    series[3] = []
    series[4] = []
    
    time_range.step(900) do |fifteen|
      series[0] << fifteen.to_minute_format
      if data.size > 0 and data[0][:grain_15_min].to_minute_format == fifteen.to_minute_format
        fact_for_this_dim = data.shift
        series[1] << fact_for_this_dim[:mem_available]
        series[2] << fact_for_this_dim[:mem_used]
        series[3] << fact_for_this_dim[:swap_available]
        series[4] << fact_for_this_dim[:swap_used]
      else
        series[1] << -1
        series[2] << -1
        series[3] << -1
        series[4] << -1
      end
    end
    
    series
  end
  
  def load_5_min
    self.loads.last.load_5_min if self.loads.last
  end
  
  def load_10_min
    self.loads.last.load_10_min if self.loads.last
  end
  
  def load_15_min
    self.loads.last.load_15_min if self.loads.last
  end
  
  def status
    if self.last_contacted_on == nil
      0
    elsif Time.now - self.last_contacted_on < 90
      5
    elsif Time.now - self.last_contacted_on < 180
      3
    elsif Time.now - self.last_contacted_on < 300
      2
    else
      1
    end
  end
  
  def to_google_params
    
  end
  
end
