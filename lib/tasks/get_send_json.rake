require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Getting json response from api & sending it to AWS."

task :get_send_json do
    puts "Getting access token..."
    urlOAuth = ENV['URL_AUTH']
    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    data = {
      grant_type: 'client_credentials',
      scope: 'read-data',
      client_id: client_id,
      client_secret: client_secret
    }

    result = RestClient.post( urlOAuth, data )
    result = JSON.parse(result)

    token = result['access_token']
    puts "Access token received, now requesting json response..."
    
    api_url = ENV['API_URL']

    api_headers = {
      'Accept-Encoding': 'gzip',
      'Authorization': 'Bearer ' + token
    }

    final_result = RestClient.get( api_url, headers = api_headers )
    json_data = JSON.parse(ActiveSupport::Gzip.decompress(final_result))

    time = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    file_name = time

    puts "Writing json file..."
    File.write("tmp/storage/#{file_name}.json", json_data.to_json)
    file_location = File.open("tmp/storage/#{file_name}.json")

    puts "Sending json file to storage..."
    profile_name = ENV['PROFILE_NAME']
    region = ENV['AWS_REGION']
    bucket = ENV['S3_BUCKET']

    s3 = Aws::S3::Client.new(profile: profile_name, region: region)

    s3.put_object(bucket: bucket, key: "#{file_name}.json", body: file_location)
    puts "Done!"

    puts "Updating daily file..."

    day = Time.now.strftime('%Y-%m-%d')
    daily_file_location = File.read("tmp/storage/#{day}-daily.json")
    daily_file = JSON.parse(daily_file_location)
    single_file_location = File.read("tmp/storage/#{file_name}.json")
    single_file = JSON.parse(single_file_location)

    journey_daily = daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney']
    journey_single = single_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney']

    journey_single.each do |single|
      if journey_daily.find { |d| d['DatedVehicleJourneyRef'] == single['DatedVehicleJourneyRef'] }
          daily = journey_daily.find { |d| d['DatedVehicleJourneyRef'] == single['DatedVehicleJourneyRef'] }
          daily_index = journey_daily.index(daily)

          time_daily = Time.parse(daily['RecordedAtTime'])
          time_single = Time.parse(single['RecordedAtTime'])

          if time_daily < time_single
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['RecordedAtTime'] = single['RecordedAtTime']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['LineRef'] = single['LineRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['DirectionRef'] = single['DirectionRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['DatedVehicleJourneyRef'] = single['DatedVehicleJourneyRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['VehicleMode'] = single['VehicleMode']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['RouteRef'] = single['RouteRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['PublishedLineName'] = single['PublishedLineName']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['DirectionName'] = single['DirectionName']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['OriginRef'] = single['OriginRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['DestinationRef'] = single['DestinationRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['DestinationName'] = single['DestinationName']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['OperatorRef'] = single['OperatorRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['ProductCategoryRef'] = single['ProductCategoryRef']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['FirstOrLastJourney'] = single['FirstOrLastJourney']
            daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['OrigineFile'] = file_name
          end

          single_calls = single['EstimatedCalls']['EstimatedCall']
          daily_calls = daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall']

          single_calls.each do |single_call|
            if daily_calls.find { |c| c['StopPointRef'] == single_call['StopPointRef'] }
              call = daily_calls.find { |c| c['StopPointRef'] == single_call['StopPointRef'] }
              call_index = daily_calls.index(call)
            
            if single_call['ExpectedDepartureTime'] != nil
              time_departure = Time.parse(single_call['ExpectedDepartureTime'])
              if time_departure > time_daily
                daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'][call_index] = single_call
                daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'][call_index]['OrigineFile'] = file_name
              end
            end
            if single_call['ExpectedDepartureTime'] == nil && single_call['ExpectedArrivalTime'] != nil
              time_arrival = Time.parse(single_call['ExpectedArrivalTime'])
              if time_arrival > time_daily
                daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'][call_index] = single_call
                daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'][call_index]['OrigineFile'] = file_name
              end
            end

            else
              daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'] << single_call
              single_call_index = daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'].index(single_call)
              daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][daily_index]['EstimatedCalls']['EstimatedCall'][single_call_index]['OrigineFile'] = file_name           
            end
          end

      else
        daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'] << single
        single_index = daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'].index(single)
        daily_file['Siri']['ServiceDelivery']['EstimatedTimetableDelivery'][0]['EstimatedJourneyVersionFrame'][0]['EstimatedVehicleJourney'][single_index]['OrigineFile'] = '2020-11-29_19-40-15'
      end
    end

    puts "Saving daily file..."
    File.write("tmp/storage/#{day}-daily.json", daily_file.to_json)
    puts "Done!"

end