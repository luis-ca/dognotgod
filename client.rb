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
      
      begin
        RestClient.post("#{@endpoint}/loads", :load_5_min => avgs[0], :load_10_min => avgs[1], :load_15_min => avgs[2], :hostname => hostname)
        puts "OK"
      rescue
        puts "There was a problem connecting to the server on #{@endpoint}."
      end
    end
    
  end
  
end

DogNotGod::Client.new(ARGV).run!