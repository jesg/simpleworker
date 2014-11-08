require 'simpleworker'

tasks = ['first', 'second', 'third']
redis = Redis.new
ssh_worker = SimpleWorker::SshWorker.new(
  :host    => 'localhost',
  :cmd     => 'ruby -s worker.rb',
  # rsync will wipe out existing files in ~/my_unused_dir
  :dirname => 'my_unused_dir')

runner = SimpleWorker::Runner.new(redis, tasks,
                                  :notify => [ssh_worker])
runner.run
