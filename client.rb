require 'rubygems'
require 'rest_client'

hostname = %x[hostname].split("\n")[0]
uptime = %x[uptime]
avgs = uptime.scan(/(\d+\.\d\d)/)

RestClient.post('http://localhost:4567/loads', :load_5_min => avgs[0], :load_10_min => avgs[1], :load_15_min => avgs[2], :hostname => hostname)

