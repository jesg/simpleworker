require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe Runner do
    let(:redis)              { double(Redis, :script => nil) }
    let(:tasks)              { ['ask1', 'task2'] }
    let(:hostname)           { 'my_hostname' }
    let(:jobid)              { 'my_jobid' }
    let(:runner)             { Runner.new(redis, tasks, :timeout => 120, :interval => 0) }
    let(:mock_event_monitor) { double(EventMonitor, :update => nil) }
    let(:mock_event_server)  { double(EventServer, :add_observer => nil) }
    let(:listener)           { double(AbstractListener, :update => nil) }

    before(:each) do
      ::SecureRandom.should_receive(:hex).with(6).and_return(jobid)

      EventServer.should_receive(:new).and_return(mock_event_server)
      EventMonitor.should_receive(:new).and_return(mock_event_monitor)
      redis.should_receive(:rpush).with("simpleworker:tasks:#{jobid}", tasks)

      redis.should_receive(:multi)
    end

    it 'can run' do
      mock_event_monitor.should_receive(:done?).and_return(false, true)
      mock_event_server.should_receive(:pull_events).and_return(2, 0)
      mock_event_monitor.should_receive(:latest_time).and_return(Time.now)
      runner.add_observer listener
      listener.should_receive(:update).with("on_start", jobid)
      listener.should_receive(:update).with("on_stop")

      runner.run
    end

    it 'can timeout' do
      mock_event_monitor.should_receive(:done?).and_return(false)
      mock_event_server.should_receive(:pull_events).and_return(2, 2)
      mock_event_monitor.should_receive(:latest_time).and_return(Time.now)

      runner = Runner.new(redis, tasks, :timeout => 0, :interval => 0)
      runner.add_observer listener
      listener.should_receive(:update).with("on_timeout")

      runner.run
    end

    it 'fires on_interrupted and shuts down if interrupted' do
      runner.add_observer listener

      mock_event_server.should_receive(:pull_events).and_raise(Interrupt)
      listener.should_receive(:update).with("on_interrupted")

      runner.run
    end

    it 'fires on_interrupted and shuts down if an error occurs' do
      runner.add_observer listener

      mock_event_server.should_receive(:pull_events).and_raise(StandardError)
      listener.should_receive(:update).with("on_interrupted")

      lambda { runner.run }.should raise_error(StandardError)
    end
  end
end
