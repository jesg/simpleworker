require 'simpleworker'

tasks = ['first', 'second', 'third']
redis = Redis.new
local_worker = SimpleWorker::LocalWorker.new("ruby", "worker.rb")
runner = SimpleWorker::Runner.new(redis, tasks,
                                  :notify => [local_worker])
runner.run
