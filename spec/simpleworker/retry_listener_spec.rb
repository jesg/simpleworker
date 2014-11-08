require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe RetryListener do
    let(:redis)     { double(Redis) }
    let(:namespace) { 'my_namespace' }
    let(:jobid)     { 'my_jobid' }
    let(:hostname)  { 'my_hostname' }
    let(:jobid)     { 'my_jobid' }

    it 'does not retry if max retries is 0' do
      listener = RetryListener.new(redis, 0, namespace, jobid)
      redis.should_not_receive(:rpush)

      listener.on_task_expire(hostname, jobid)
      listener.tasks.should be_empty
    end

    it 'does retry once if max retries is 1' do
      listener = RetryListener.new(redis, 1, namespace, jobid)
      redis.should_receive(:rpush).once

      2.times { listener.on_task_expire(hostname, jobid) }
      listener.tasks.should_not be_empty
    end
  end
end
