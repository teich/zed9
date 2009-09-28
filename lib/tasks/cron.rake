task :cron => :environment do
  puts "Calculating Averages"
  Average.calc_averages!
  puts "done."
end