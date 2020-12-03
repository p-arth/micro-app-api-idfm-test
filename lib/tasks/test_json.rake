require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Testing."

task :test_json do

    # day = Time.now.strftime('%Y-%m-%d')
    # daily_file_location = File.read("tmp/storage/#{day}-daily.json")

    daily_file_location = File.read("tmp/storage/2020-11-29-daily.json")
    daily_file = JSON.parse(daily_file_location)

    single_file_location = File.read("tmp/storage/2020-11-29_19-40-15.json")
    single_file = JSON.parse(single_file_location)

    # Single is more recent
    journey_daily = daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney']
    journey_single = single_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney']

    journey_single.each do |single|
        if journey_daily.find { |d| d['DatedVehicleJourneyRef'] == single['DatedVehicleJourneyRef'] }
            daily = journey_daily.find { |d| d['DatedVehicleJourneyRef'] == single['DatedVehicleJourneyRef'] }
            daily_index = journey_daily.index(daily)

            time_daily = Time.parse(daily['RecordedAtTime'])
            time_single = Time.parse(single['RecordedAtTime'])

            if time_daily < time_single
                daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index] = single
            end
        else
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'] << single
        end
    end

    puts "Updating daily file..."
    File.write("tmp/storage/2020-11-29-daily.json", daily_file.to_json)
    
end