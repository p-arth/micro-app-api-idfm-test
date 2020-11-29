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
    puts daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][0]['RecordedAtTime']

end