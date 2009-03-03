require File.dirname(__FILE__) + '/base'
require 'lib/client_commands.rb'
require 'restclient'

describe DogNotGod::Client do
	before do
	end
  
end

describe DogNotGod::Commands::MemoryStats do

  before do
	end
  
  it "should return an array with memory info on CentOS 5.2" do
    shell_output =<<MARKER
             total       used       free     shared    buffers     cached
Mem:       1048796     726476     322320          0      86820      55796
-/+ buffers/cache:     883860     164936
Swap:      2097144     136552    1960592
MARKER

    DogNotGod::Shell.stub!(:call).with("free").and_return(shell_output)
    @mem_stats_command = DogNotGod::Commands::MemoryStats.new
    expected_output = { :mem_available => "322320",  :mem_used => "726476", :swap_available => "1960592", :swap_used => "136552" }
    
    @mem_stats_command.get_memory_and_swap_statistics_from_shell.should ===(expected_output)
  end

  it "should post stats to the /memory_stats resource" do
    @resource = mock(RestClient::Resource)
    @resource.should_receive(:[]).with("/mem_stats").once.and_return(@resource)
    @resource.should_receive(:post).with({:hostname => "my_host_name", :mem_available => "11111", :mem_used => "22222", :swap_available => "33333", :swap_used => "44444" })
    
    @command = DogNotGod::Commands::MemoryStats.new
    @command.should_receive(:get_hostname_from_shell).and_return("my_host_name")
    @command.should_receive(:get_memory_and_swap_statistics_from_shell).and_return({ :mem_available => "11111",  :mem_used => "22222", :swap_available => "33333", :swap_used => "44444" })
    @command.run!(@resource)
  end
end

describe DogNotGod::Commands::DiskStats do

  before do
	end
  
  it "should return an array with fs info on OSX 10.5" do
    shell_output =<<MARKER
Filesystem    1024-blocks      Used Available Capacity  Mounted on
/dev/disk0s2    142141960 102909920  38976040    73%    /
devfs                 110       110         0   100%    /dev
/dev/disk0s3     52752040  14945552  37806488    29%    /Volumes/HD2
/dev/disk3s2       294924    264848     30076    90%    /Volumes/GIMP 2.6.4 Leopard universal
MARKER

    DogNotGod::Shell.stub!(:call).with("df -ak").and_return(shell_output)
    @disk_stats_command = DogNotGod::Commands::DiskStats.new
    expected_output = []
    expected_output << %w(/dev/disk0s2    142141960 102909920  38976040    /)
    expected_output << %w(/dev/disk0s3     52752040  14945552  37806488    /Volumes/HD2)
    expected_output << ["/dev/disk3s2", "294924", "264848", "30076", '/Volumes/GIMP 2.6.4 Leopard universal']
    
    @disk_stats_command.get_disk_statistics_from_shell.should eql(expected_output)
  end
  
  it "should return an array with fs info on CentOS 5.2" do
    shell_output =<<MARKER
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mapper/VolGroup00-LogVol00
                       6983168   3044884   3577836  46% /
proc                         0         0         0   -  /proc
sysfs                        0         0         0   -  /sys
devpts                       0         0         0   -  /dev/pts
/dev/sda1               101086     17860     78007  19% /boot
tmpfs                   517644         0    517644   0% /dev/shm
none                         0         0         0   -  /proc/sys/fs/binfmt_misc
sunrpc                       0         0         0   -  /var/lib/nfs/rpc_pipefs
MARKER

    DogNotGod::Shell.stub!(:call).with("df -ak").and_return(shell_output)
    @disk_stats_command = DogNotGod::Commands::DiskStats.new
    expected_output = []
    expected_output << %w(/dev/mapper/VolGroup00-LogVol00   6983168   3044884   3577836 /)
    expected_output << %w(/dev/sda1               101086     17860     78007 /boot)


    @disk_stats_command.get_disk_statistics_from_shell.should eql(expected_output)
  end
  
  it "should post stats to the /file_system_stats resource" do
    @resource = mock(RestClient::Resource)
    @resource.should_receive(:[]).with("/file_system_stats").once.and_return(@resource)
    @resource.should_receive(:post).with({:file_system_name => "/dev/sda1", :mounted_on => "/", :used => "33344", :available => "44433", :hostname => "my_host_name"})
    
    @command = DogNotGod::Commands::DiskStats.new
    @command.should_receive(:get_hostname_from_shell).and_return("my_host_name")
    @command.should_receive(:get_disk_statistics_from_shell).and_return([["/dev/sda1", nil, "33344", "44433", "/"]])
    @command.run!(@resource)
  end
end

describe DogNotGod::Commands::LoadStats do
  
  before do
	end
  
  it "should return an array with averages on OSX 10.5" do
    shell_output =<<MARKER
21:58  up 48 days,  3:50, 9 users, load averages: 0.93 1.04 0.99
MARKER
    
    DogNotGod::Shell.stub!(:call).with("uptime").and_return(shell_output)
    @load_stats_command = DogNotGod::Commands::LoadStats.new
    @load_stats_command.get_load_averages_from_shell.should eql([["0.93"], ["1.04"], ["0.99"]])
  end

  it "should return an array with averages on CentOS 5.2" do
    shell_output =<<MARKER
 16:43:57 up 21 days,  2:01,  1 user,  load average: 0.66, 1.04, 0.52
MARKER

    DogNotGod::Shell.stub!(:call).with("uptime").and_return(shell_output)
    @load_stats_command = DogNotGod::Commands::LoadStats.new
    @load_stats_command.get_load_averages_from_shell.should eql([["0.66"], ["1.04"], ["0.52"]])
  end
  
  it "should post stats to the /load_stats resource" do
    @resource = mock(RestClient::Resource)
    @resource.should_receive(:[]).with("/load_stats").once.and_return(@resource)
    @resource.should_receive(:post).with({:hostname => "my_host_name", :load_5_min => 0.24, :load_10_min => 0.33, :load_15_min => 0.54})    

    @command = DogNotGod::Commands::LoadStats.new
    @command.should_receive(:get_hostname_from_shell).and_return("my_host_name")
    @command.should_receive(:get_load_averages_from_shell).and_return([0.24,0.33,0.54])
    @command.run!(@resource)
  end
end
