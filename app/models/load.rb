class Load < Sequel::Model
  
    many_to_one :hosts
  
	unless table_exists?
		set_schema do
			primary_key :id
		  integer :host_id
			float :load_5_min
			float :load_10_min
			float :load_15_min
			timestamp :created_at
			timestamp :grain_5_min
		end
		create_table
	end
end
