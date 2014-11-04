require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe EventServer do
    let(:redis)            { double(Redis) }
    let(:namespace)        { 'my_namespace' }
    let(:jobid)            { 'my_jobid' }
    let(:event_server)     { EventServer.new(redis, namespace, jobid) }
    let(:log_key)          { "#{namespace}:log:#{jobid}" }
    let(:active_tasks_key) { "#{namespace}:active:#{jobid}" }
    let(:tasks_key)        { "#{namespace}:tasks:#{jobid}" }

    it 'can pull events' do
      expect(redis).to receive(:multi).and_return([[["event"].to_json], [["#{namespace}:active:#{jobid}:my_hostname:my_task"],["#{namespace}:active:#{jobid}:my2_hostname:my2_task"]], 0])

      expect(event_server).to receive(:fire).with("event")
      expect(event_server).to receive(:fire).with('on_task_expire', 'my_hostname', 'my_task')
      expect(event_server).to receive(:fire).with('on_task_active', 'my2_hostname', 'my2_task')

      result = event_server.pull_events
      expect(result).to eq(0)
    end
  end
end
