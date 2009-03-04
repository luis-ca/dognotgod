require 'rubygems'
require 'optparse'
require 'restclient'
require 'lib/base.rb'
require 'lib/client_commands.rb'

module DogNotGod

  class Client
    
    capture [:load_stats, :disk_stats, :memory_stats]
    
    def initialize(argv)
      
      @argv = argv
      
      # Default options values
      @options = {
        :server_addr                => "127.0.0.1",
        :server_port                => "4567",
        :timeout                    => 10
      }
      
      parse!
      
      @resource = RestClient::Resource.new("http://#{@options[:server_addr]}:#{@options[:server_port]}")
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
      
      @@command_symbols.each do |command_name_symbol|
        begin
          command = DogNotGod::Commands.factory(command_name_symbol)
          command.run!(@resource)
        rescue
          raise
        end
      end
      
    end
    
  end
  
end

DogNotGod::Client.new(ARGV).run!
