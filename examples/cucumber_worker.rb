require 'simpleworker'
require 'cucumber/cli/main'

redis      = Redis.new
task_queue = SimpleWorker::TaskQueue.new(redis, 'my_hostname', ENV['JOBID'])

task_queue.fire_start

task_queue.each_task do |task|
  status = nil
  begin
    Cucumber::Cli::Main.execute [task]
  rescue SystemExit => e
    status = e.success?
  end

  task_queue.fire_log_message "Cucumber task: #{task} status: #{status}"
end

task_queue.fire_stop
