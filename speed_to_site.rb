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
  
  desc "Start TARGET", "Start a speed test of Target"
  
  method_option :runs, :type => :numeric, :default => 100, :desc => "Number of tests"
  
  def start(args)
    target = args
    runs = options[:runs]
    a = []


    puts "checking speed to #{target}"
    puts "I will test the speed #{runs} times"

    runs.times do
    	b = `curl -sSLw \"%{http_code} total_time=%{time_total} time_connect=%{time_connect} time_start=%{time_starttransfer} %{url_effective}\\n\" #{target} -o /dev/null`
    	a << b.split[1].split("=")[1].to_f
    end

    avg_a = a.inject(0){|sum,x| sum + x } / runs
    a.sort!
    perc99_a = a.value_from_percentile(99)
    perc95_a = a.value_from_percentile(95)
    if perc99_a.nil?
      perc99_a = a.last
    end

    if perc95_a.nil?
      perc95_a = a.last
    end

    puts "Over the #{runs} tests, the average time was #{avg_a}, the perc95 was #{perc95_a} and the perc99 was #{perc99_a}."
  end
end

SpeedTest.start