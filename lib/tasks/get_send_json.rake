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

    # Update daily file
    # puts "Updating daily file..."

    # day = Time.now.strftime('%Y-%m-%d')
    # daily_file_location = File.open("tmp/storage/#{day}-daily.json")

    # daily_file = JSON.parse(ActiveSupport::Gzip.decompress(daily_file_location))
    # puts daily_file('Siri')('ServiceDelivery')('EstimatedTimetableDelivery')[0]('EstimatedJourneyVersionFrame')[0]('EstimatedVehicleJourney')[0]('RecordedAtTime')

end