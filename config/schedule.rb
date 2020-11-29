set :output, "/home/justsomeguy/code/suavy/micro-app-api-idfm/log/cron_log.log"
set :bundle_command, "/home/justsomeguy/.rbenv/shims/bundle exec"




every 1.day, at: '0:00 am' do
    rake 'daily_json'
end

every 5.minutes do
    rake 'get_send_json'
end

every 1.day, at: '11:57 pm' do
    rake 'send_daily_json'
    rake 'cleanup'
end

# every 1.minute do
#     rake 'tmp:clear'
# end

# every 30.minutes do
#     rake 'tmp:storage:clear'
# end