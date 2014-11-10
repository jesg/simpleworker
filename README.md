SimpleWorker
============

Distribute automation tasks on multiple machines.

Usage
=====

Ruby must be setup on the remote host such that it is available in the user's login shell.

```ruby
require 'simpleworker'

tasks = ['first', 'second', 'third']
redis = Redis.new

# create a remote worker
ssh_worker = SimpleWorker::SshWorker.new(
  :user    => 'jesg'
  :host    => 'localhost',
  :cmd     => 'ruby -s worker.rb',
  # rsync will wipe out existing files in ~/my_unused_dir
  :dirname => 'my_unused_dir')

# create a local worker
local_worker = SimpleWorker::LocalWorker.new("ruby", "worker.rb")

runner = SimpleWorker::Runner.new(redis, tasks,
  :namespace   => 'custom_namespace',          # redis key prefix
  :notify      => [local_worker, ssh_worker],  # listeners that implement AbstractListener
  :max_retries => 1,                           # max times expired tasks will be retried
  :timeout     => 60,                          # timout if inactive
  :interval    => 2)                           # interval at which to pull events from redis in seconds

runner.run

```

Next create a script to work on the automation tasks.

```ruby
require 'simpleworker'

redis      = Redis.new
task_queue = SimpleWorker::TaskQueue.new(redis, 'my_hostname', ENV['JOBID'])

task_queue.fire_start

task_queue.each_task do |task|
  task_queue.fire_log_message(task)
end

task_queue.fire_stop
```

Examples
========

[Distribute cucumber scenarios](http://jesg.github.io/testing/2014/08/23/distributed-cucumber.html)

Requirements
===========
 * redis

Note on Patches/Pull Requests
=============================

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
