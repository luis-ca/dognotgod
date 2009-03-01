require 'rubygems'
require 'optparse'
require 'restclient'

module DogNotGod

  class Client

    def initialize(argv)
      @argv = argv
      
      # Default options values
      @options = {
        :server_addr                => "127.0.0.1",
        :server_port                => "4567",
        :timeout                    => 5
      }
      
      parse!
      
      @endpoint = "http://#{@options[:server_addr]}:#{@options[:server_port]}"
    end
    
    def parser
      # NOTE: If you add an option here make sure the key in the +options+ hash is the
      # same as the name of the command line option.
      # +option+ keys are used to build the command line to launch other processes,
      # see <tt>lib/thin/command.rb</tt>.
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: dognotgod-client [options]"
        opts.separator ""
        opts.separator "Server options:"

        opts.on("-a", "--server-addr HOST", "HOST address to call (default: #{@options[:server_addr]})")  { |host| @options[:server_addr] = host }
        opts.on("-p", "--server-port PORT", "use PORT (default: #{@options[:server_port]})")                  { |port| @options[:server_port] = port.to_i }
        #opts.on("-t", "--timeout SECONDS", "timeout after SECONDS (default: #{@options[:timeout]})")                         { |port| @options[:timeout] = port.to_i }
        opts.separator ""
      end
    end
    
    # Parse the options.
    def parse!
      parser.parse! @argv
      @arguments = @argv
    end

    def run!
      hostname = %x[hostname].split("\n")[0]
      uptime = %x[uptime]
      avgs = uptime.scan(/(\d+\.\d\d)/)
      
      
      # the 'free' command is not available on Mac OSX
      mem = %x[free].split("\n")
      mem.shift # lose column headers
      mem_available = mem[0].split(" ")[3]
      mem_used = mem[0].split(" ")[2]
      swap_available = mem[2].split(" ")[3]
      swap_used = mem[2].split(" ")[2]
      
      
      df = %x[df -ak].split("\n")
      df.shift # lose column headers
      
      begin
       RestClient.post("#{@endpoint}/loads", :load_5_min => avgs[0], :load_10_min => avgs[1], :load_15_min => avgs[2], :hostname => hostname)
        puts "Load info sent successfully."
        
        df.each do |line|
          info = line.split(" ")
          RestClient.post("#{@endpoint}/disks", :filesystem => info[0], :mounted_on => info[-1], :used => info[2], :available => info[3], :hostname => hostname)
        end
        puts "Filesystem info sent successfully."
        
        RestClient.post("#{@endpoint}/mem_stats", :hostname => hostname, :mem_available => mem_available, :mem_used => mem_used, :swap_available => swap_available, :swap_used => swap_used)
        puts "Memory and swap info sent successfully."
        
      rescue
        puts "There was a problem connecting to the server on #{@endpoint}."
      end
    end
    
  end
  
end

DogNotGod::Client.new(ARGV).run!