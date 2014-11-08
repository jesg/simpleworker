require 'simpleworker'

redis      = Redis.new
task_queue = SimpleWorker::TaskQueue.new(redis, 'my_hostname', ENV['JOBID'])

task_queue.fire_start

task_queue.each_task do |task|
  puts "Task: #{task}"
end

task_queue.fire_stop
