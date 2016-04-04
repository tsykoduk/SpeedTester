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
    a = []
    c = []
    File.open("out.txt", 'w') {|f|
      f.puts "Start of run"
    }

    puts "checking speed to #{target}"
    puts "I will test the speed #{runs} times"
    
    runs.times do
    	b = `curl -sSLw \"http_code=%{http_code} total_time=%{time_total} time_connect=%{time_connect} time_start=%{time_starttransfer} %{url_effective}\\n\" #{target} -o /dev/null`
    	a << b.split[1].split("=")[1].to_f
      c << b.split[1].split("=")[1].to_f - b.split[3].split("=")[1].to_f
      File.open("out.txt", 'a') {|f|
        f.puts b
      }
      #if we are running locally
      #print "."
      puts b
    end
  
    avg_c = c.inject(0){|sum,x| sum + x } / runs * 1000
    avg_a = a.inject(0){|sum,x| sum + x } / runs * 1000
    a.sort!
    perc99_a = a.value_from_percentile(99)
    perc95_a = a.value_from_percentile(95)
    if perc99_a.nil?
      perc99_a = a.last * 1000
    else
      perc99_a = perc99_a * 1000
    end

    if perc95_a.nil?
      perc95_a = a.last * 1000
    else
      perc95_a = perc95_a * 1000
    end
    
    results = "Over the #{runs} tests, the average time was #{avg_a.to_i}ms, the perc95 was #{perc95_a.to_i}ms and the perc99 was #{perc99_a.to_i}ms. The average time in the router was #{avg_c.to_i}"
    
   File.open("out.txt",'a') {|f| 
     f.puts results
   }
    puts "\r" + results + " Detailed output is in file out.txt"
  end
end

SpeedTest.start