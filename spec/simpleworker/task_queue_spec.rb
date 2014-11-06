require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe TaskQueue do
    let(:redis) { double(Redis, :script => 'my_sha') }
    let(:jobid) { 'my_jobid' }
    let(:task) { 'my_task' }
    let(:hostname) { 'my_hostname' }
    let(:task_queue) { TaskQueue.new(redis, hostname, jobid) }

    it 'can log node start' do
      redis.should_receive(:rpush).with('simpleworker:log:my_jobid', ['on_node_start', hostname].to_json)

      task_queue.on_start
    end

    it 'can log node stop' do
      redis.should_receive(:rpush).with('simpleworker:log:my_jobid', ['on_node_stop', hostname].to_json)

      task_queue.on_stop
    end

    it 'can log task start' do
      redis.should_receive(:rpush).with('simpleworker:log:my_jobid', ['on_task_start', hostname, task].to_json)

      task_queue.on_task_start(task)
    end

    it 'can log task stop' do
      redis.should_receive(:rpush).with('simpleworker:log:my_jobid', ['on_task_stop', hostname, task].to_json)

      task_queue.on_task_stop(task)
    end

    it 'can pop from reliable queue' do
      redis.should_receive(:evalsha).and_return('first_task', 'second_task', nil)
      redis.should_receive(:srem).with("simpleworker:active:#{jobid}", "simpleworker:active:#{jobid}:#{hostname}:first_task")
      redis.should_receive(:srem).with("simpleworker:active:#{jobid}", "simpleworker:active:#{jobid}:#{hostname}:second_task")

      task_queue.pop.should eq 'first_task'
      task_queue.pop.should eq 'second_task'
      task_queue.pop.should be nil
    end
  end
end