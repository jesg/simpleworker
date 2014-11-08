require 'simpleworker'

tasks = ['first', 'second', 'third']
redis = Redis.new
runner = SimpleWorker::Runner.new(redis, tasks)

worker_thread = Thread.new do
  task_queue = SimpleWorker::TaskQueue.new(redis, 'my_hostname', runner.jobid)

  task_queue.fire_start

  task_queue.each_task do |task|
    puts "Task: #{task}"
  end

  task_queue.fire_stop
end

runner.run
