require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Testing."

task :test_json do

    day = Time.now.strftime('%Y-%m-%d')
    daily_file_location = File.read("tmp/storage/#{day}-daily.json")

    daily_file = JSON.parse(daily_file_location)
    time1 = Time.parse(daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][0]['RecordedAtTime'])
    time2 = Time.parse(daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][1]['RecordedAtTime'])
    # puts Time.parse(time)
    puts time1
    puts time2

    puts time1 > time2

    

end