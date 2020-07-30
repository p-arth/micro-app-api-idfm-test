require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Getting json response from api & sending it to AWS."

task :get_send_json do
    urlOAuth = 'https://as.api.iledefrance-mobilites.fr/api/oauth/token'
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

    api_url = 'https://traffic.api.iledefrance-mobilites.fr/v1/tr-global/estimated-timetable'

    api_headers = {
      'Accept-Encoding': 'gzip',
      'Authorization': 'Bearer ' + token
    }

    final_result = RestClient.get( api_url, headers = api_headers )
    json_data = JSON.parse(ActiveSupport::Gzip.decompress(final_result))

    time = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    file_name = time

    File.write("tmp/storage/#{file_name}.json", json_data)
    file_location = File.open("tmp/storage/#{file_name}.json")

    profile_name = 'p-arth'
    region = ENV['AWS_REGION']
    bucket = ENV['S3_BUCKET']

    s3 = Aws::S3::Client.new(profile: profile_name, region: region)

    s3.put_object(bucket: bucket, key: "#{file_name}.json", body: file_location)


end