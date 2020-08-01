set :output, "/home/justsomeguy/code/suavy/micro-app-api-idfm/log/cron_log.log"
set :bundle_command, "/home/justsomeguy/.rbenv/shims/bundle exec"


every 5.minutes do
    rake 'get_send_json'
end