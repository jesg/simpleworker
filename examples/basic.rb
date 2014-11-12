require 'simpleworker'

tasks = ['first', 'second', 'third']
redis = Redis.new
runner = SimpleWorker::Runner.new(redis, tasks,
                                  :max_retries => 2)

worker_thread = Thread.new do
  task_queue = SimpleWorker::TaskQueue.new(redis, 'my_hostname', runner.jobid)

  task_queue.fire_start

  task_queue.each_task do |task|
    if task == 'first'
      sleep 15
    elsif task == 'second'
      task_queue.expire_current_task
    else
      task_queue.fire_log_message "Task: #{task}"
    end
  end

  task_queue.fire_stop
end

runner.run
