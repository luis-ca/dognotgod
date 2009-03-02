class Disk < Sequel::Model
  
  many_to_one :filesystems
  
	unless table_exists?
		set_schema do
			primary_key :id
			integer :file_system_id
			string :mounted_on
			integer :used
			integer :available
			timestamp :created_at
			timestamp :grain_5_min
			timestamp :grain_15_min
			timestamp :grain_30_min
			timestamp :grain_60_min
		end
		create_table
	end
	
  before_create do
    self.created_at = Time.now.utc unless self.created_at
    self.grain_5_min = self.created_at.to_five_minute_grain_format
    self.grain_15_min = self.created_at.to_fifteen_minute_grain_format
    self.grain_30_min = self.created_at.to_thirty_minute_grain_format
    self.grain_60_min = self.created_at.to_sixty_minute_grain_format
  end
end
