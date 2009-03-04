class FileSystem < Sequel::Model
  
  many_to_one :hosts
  one_to_many :disks
  
  def latest_disk_entry
    @latest_disk_entry ||= self.disks_dataset.order(:created_at).last
  end
  
	unless table_exists?
		set_schema do
			primary_key :id
		  integer :host_id
			string :name
			string :mounted_on
			timestamp :created_at
		end
		create_table
	end
	
	def is_dev?
	  self.name.scan(/^\/dev/).size > 0
	end
	
	def size_in_Gb
    available_in_Gb + used_in_Gb
  end
  
	def used_in_Gb
	  if latest_disk_entry
      latest_disk_entry.used / 1024 / 1024
    else
      0
    end
  end
  
	def available_in_Gb
	  if latest_disk_entry
      latest_disk_entry.available / 1024 / 1024
    else
      0
    end
  end
	
  def disks_5_min_grain(start_time, end_time)
    disk = DB.fetch("SELECT ROUND(AVG(available)/1024/1024, 1) AS available, ROUND(AVG(used)/1024/1024, 1) AS used, grain_5_min FROM disks WHERE file_system_id = #{self.id} AND grain_5_min >= '#{start_time.to_five_minute_grain_format.to_sql_format}' AND grain_5_min <= '#{end_time.to_five_minute_grain_format.to_sql_format}' GROUP BY grain_5_min;").all
    
    time_range = (start_time..end_time)
    
    series = []
    series[0] = []
    series[1] = []
    series[2] = []
    series[3] = []
    time_range.step(300) do |five|
      series[0] << five.to_minute_format
      if disk.size > 0 and disk[0][:grain_5_min].to_minute_format == five.to_minute_format
        disk_for_this_dim = disk.shift
        series[1] << (disk_for_this_dim[:available] + disk_for_this_dim[:used])
        series[2] << disk_for_this_dim[:used]
      else
        series[1] << -1
        series[2] << -1
      end
    end
    
    series
  end
  
  def disks_15_min_grain(start_time, end_time)
    disk = DB.fetch("SELECT ROUND(AVG(available)/1024/1024, 1) AS available, ROUND(AVG(used)/1024/1024, 1) AS used, grain_15_min FROM disks WHERE file_system_id = #{self.id} AND grain_15_min >= '#{start_time.to_fifteen_minute_grain_format.to_sql_format}' AND grain_15_min <= '#{end_time.to_fifteen_minute_grain_format.to_sql_format}' GROUP BY grain_15_min;").all
    
    time_range = (start_time..end_time)
    
    series = []
    series[0] = []
    series[1] = []
    series[2] = []
    series[3] = []
    time_range.step(900) do |fifteen|
      series[0] << fifteen.to_minute_format
      if disk.size > 0 and disk[0][:grain_15_min].to_minute_format == fifteen.to_minute_format
        disk_for_this_dim = disk.shift
        series[1] << (disk_for_this_dim[:available] + disk_for_this_dim[:used])
        series[2] << disk_for_this_dim[:used]
      else
        series[1] << -1
        series[2] << -1
      end
    end
    
    series
  end
	
end
