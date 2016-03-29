SpeedTester
===========

A basic command line speed testing tool.

***Usage***

`./speed_to_site.rb start URL --runs NUMBER`

Give start a URL and --runs a number of times to run the test. It will output the average, perc95 and perc99 times for the site.

***Example***

	~/Code/speed_to_site ☯ ./speed_to_site.rb start http://greg.nokes.name --runs 100
	checking speed to http://greg.nokes.name
	I will test the speed 100 times
	Over the 100 tests, the average time was 890ms, the perc95 was 949ms and the perc99 was 1978ms.

