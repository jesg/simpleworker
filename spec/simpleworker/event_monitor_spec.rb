require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe EventMonitor do
    let(:start_time)    { Time.now }
    let(:event_monitor) { EventMonitor.new(start_time = start_time) }
    let(:jobid)         { 'my_jobid' }
    let(:hostname)      { 'my_hostname' }
    let(:task)          { 'my_task' }

    it 'can initialize event monitor' do
      event_monitor = EventMonitor.new(start_time = start_time)

      expect(event_monitor.start_time).to eq(start_time)
      expect(event_monitor.latest_time).to eq(start_time)
      expect(event_monitor.expired_tasks).to be_empty
      expect(event_monitor.done?(1)).to be false
      expect(event_monitor.done?(0)).to be true
    end

    it 'can start node' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)

      expect(event_monitor.done?(0)).to be false
    end

    it 'can stop node' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_node_stop(hostname)

      expect(event_monitor.done?(0)).to be true
    end

    it 'can start task' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)

      expect(event_monitor.done?(0)).to be false
    end

    it 'can stop task' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)
      event_monitor.on_task_stop(hostname, task)

      expect(event_monitor.done?(0)).to be false
    end

    it 'can expire task' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)
      event_monitor.on_task_expire(hostname, task)

      expect(event_monitor.done?(0)).to be false
    end

    it 'can expire task and stop node' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)
      event_monitor.on_task_expire(hostname, task)
      event_monitor.on_node_stop(hostname)

      expect(event_monitor.done?(0)).to be true
    end

    it 'can complete on happy path' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)
      event_monitor.on_task_stop(hostname, task)
      event_monitor.on_node_stop(hostname)

      expect(event_monitor.done?(0)).to be true
    end

    it 'can complete with expired task' do
      event_monitor.on_start(jobid)
      event_monitor.on_node_start(hostname)
      event_monitor.on_task_start(hostname, task)
      event_monitor.on_task_expire(hostname, task)
      event_monitor.on_node_stop(hostname)

      expect(event_monitor.done?(0)).to be true
    end
  end
end
