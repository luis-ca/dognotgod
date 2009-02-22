class Host < Sequel::Model

  one_to_many :loads
  
	unless table_exists?
		set_schema do
			primary_key :id
		  text :hostname
			timestamp :created_at
		end
		create_table
	end
	
	def last_contacted_on
	  self.loads.last.created_at if self.loads.last
  end
  
  def distance_to_last_heartbeat_in_seconds
    (Time.now - self.loads.last.created_at) if self.loads.last
  end
  
  def loads_by_minute(start_time, end_time)
    DB.fetch("SELECT AVG(load_5_min) AS load_5_min, AVG(load_10_min) AS load_10_min, AVG(load_15_min) AS load_15_min, grain_5_min FROM loads WHERE host_id = #{self.id} AND grain_5_min >= '#{start_time.to_five_minute_grain_format.to_sql_format}' AND grain_5_min <= '#{end_time.to_five_minute_grain_format.to_sql_format}'  GROUP BY grain_5_min;").all
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
  
end
