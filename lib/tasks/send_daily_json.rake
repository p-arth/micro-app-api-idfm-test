require 'aws-sdk-s3'
require 'aws-sdk'
require 'json'
require 'rest-client'
require 'active_support/all'

desc "Sending daily json file to AWS."

task :send_daily_json do

    day = Time.now.strftime('%Y-%m-%d')    
    file_location = File.open("tmp/storage/#{day}-daily.json")

    puts "Sending daily json file to storage..."
    profile_name = ENV['PROFILE_NAME']
    region = ENV['AWS_REGION']
    bucket = ENV['S3_BUCKET']

    s3 = Aws::S3::Client.new(profile: profile_name, region: region)

    s3.put_object(bucket: bucket, key: "#{day}-daily.json", body: file_location)
    puts "Done!"

end