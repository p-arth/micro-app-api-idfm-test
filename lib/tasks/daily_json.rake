require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Creating daily file."

task :daily_json do

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

    day = Time.now.strftime('%Y-%m-%d')

    puts "Starting daily file..."
    File.write("tmp/storage/#{day}-daily.json", json_data)

    puts 'Done!'

end
