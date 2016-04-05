#!/usr/bin/env ruby


require 'descriptive-statistics'
require 'thor'

module Enumerable
  include DescriptiveStatistics

  # Warning: hacky evil meta programming. Required because classes that have already included
  # Enumerable will not otherwise inherit the statistics methods.
  DescriptiveStatistics.instance_methods.each do |m|
    define_method(m, DescriptiveStatistics.instance_method(m))
  end
end

class SpeedTest < Thor
  
  desc "Start TARGET [--runs (OPTIONAL)]", "Start a speed test of Target"
  
  method_option :runs, :type => :numeric, :default => 100, :desc => "Number of tests"
  
  def start(args)
    target = args
    runs = options[:runs]
    req_time = []
    router_est = []
    File.open("out.txt", 'w') {|f|
      f.puts "Start of run"
    }

    puts "checking speed to #{target}"
    puts "I will test the speed #{runs} times"
    
    runs.times do
    	b = `curl -sSLw \"http_code=%{http_code} total_time=%{time_total} time_connect=%{time_connect} time_start=%{time_starttransfer} %{url_effective}\\n\" #{target} -o /dev/null`
    	req_time << b.split[1].split("=")[1].to_f
      router_est << b.split[1].split("=")[1].to_f - b.split[3].split("=")[1].to_f
      File.open("out.txt", 'a') {|f|
        f.puts b
      }
      #if we are running locally
      #print "."
      puts b
    end
  
    avg_router_est = router_est.inject(0){|sum,x| sum + x } / runs * 1000
    avg_req_time = req_time.inject(0){|sum,x| sum + x } / runs * 1000

    perc99_router_est = check_for_nil(router_est.value_from_percentile(99), router_est)
    perc95_router_est = check_for_nil(router_est.value_from_percentile(95), router_est)
    perc99_req_time = check_for_nil(req_time.value_from_percentile(99), req_time)
    perc95_req_time = check_for_nil(req_time.value_from_percentile(95), req_time)
    
    

    
    results = "Over the #{runs} tests, the average time was #{avg_req_time.to_i}ms, the perc95 was #{perc95_req_time.to_i}ms and the perc99 was #{perc99_req_time.to_i}ms."  
    
    ## Router times are not accurate - shelving for now.
    #The average time in the router was #{avg_router_est.round(1)}ms, the perc95 was #{perc95_router_est.round(1)}ms and the perc99 was #{perc99_router_est.round(1)}ms"
    
   File.open("out.txt",'a') {|f| 
     f.puts results
   }
    puts "\r" + results + " Detailed output is in file out.txt"
  end
  
  no_commands {
  def check_for_nil(check, set)
    set.sort!
    if check.nil?
      return set.last * 1000
    else
      return check * 1000
    end
  end
}
  
end

SpeedTest.start