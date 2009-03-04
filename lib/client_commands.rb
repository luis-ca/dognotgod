module DogNotGod

  class Shell
    
    def initialize
      raise "StaticClass"
    end
    
    def self.call(command)
      `#{command}`
    end
  end

  class Client
    
    def self.capture(array_of_command_symbols)
     @@command_symbols = array_of_command_symbols
    end
    
  end

  #
  #
  #
  module Commands
    
    def self.factory(command_name_symbol)
      class_name = command_name_symbol.to_s.camelize
      klass = self.const_get class_name
      klass.new
    end
    
    
    class ClientCommand
      
      def run!(resource)
        @resource = resource
        _prepare
        _execute
      end
      
      def get_hostname_from_shell
        DogNotGod::Shell.call("hostname").split("\n")[0]
      end
      
    end
    
    # 
    # Load average statistics
    # 
    class LoadStats < ClientCommand
      
      def _prepare
        @hostname = get_hostname_from_shell
        @load_averages = get_load_averages_from_shell
      end
            
      def _execute
        @resource["/load_stats"].post({:load_5_min => @load_averages[0], :load_10_min => @load_averages[1], :load_15_min => @load_averages[2], :hostname => @hostname})
      end
      
      def get_load_averages_from_shell
        DogNotGod::Shell.call("uptime").scan(/(\d+\.\d\d)/)
      end
      
    end
    
    # 
    # Disk statistics
    #
    class DiskStats < ClientCommand
      
      def _prepare
        @hostname = get_hostname_from_shell
        @disk_stats = get_disk_statistics_from_shell
      end
      
      def _execute
        @disk_stats.each do |line|
          @resource["/file_system_stats"].post({:file_system_name => line[0], :mounted_on => line[-1], :used => line[2], :available => line[3], :hostname => @hostname})
        end
      end
  
      # 
      # Extract disk data from df call
      #
      # - Only extract entries for filesystems starting with a /
      # - Ignore capacity % column
      # 
      def get_disk_statistics_from_shell
        DogNotGod::Shell.call("df -ak").scan(/^(\/[\w+\/-]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+\%\s+(\/.*)\n/)
      end
      
    end
    
    #
    # Memory statistics, including swap
    #
    class MemoryStats < ClientCommand
      
      def _prepare
        @hostname = get_hostname_from_shell
        @memory_stats = get_memory_and_swap_statistics_from_shell
      end
      
      def _execute
        @resource["/mem_stats"].post({:hostname => @hostname, :mem_available => @memory_stats[:mem_available], :mem_used => @memory_stats[:mem_used], :swap_available => @memory_stats[:swap_available], :swap_used => @memory_stats[:swap_used]})
      end
      
      def get_memory_and_swap_statistics_from_shell
        # Note: the 'free' command is not available on Mac OSX
        mem = DogNotGod::Shell.call("free").split("\n")
        mem.shift # lose column headers
        
        {:mem_available => mem[0].split(" ")[3], :mem_used => mem[0].split(" ")[2], :swap_available => mem[2].split(" ")[3], :swap_used  => mem[2].split(" ")[2] }
      end

    end
  end
  
end