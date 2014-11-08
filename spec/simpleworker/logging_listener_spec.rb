require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe LoggingListener do
    let(:stdout)    { StringIO.new }
    let(:listener) { LoggingListener.new stdout }

    it 'logs all events' do
      Time.stub(:now => Time.now)

      jobid = 'my_jobid'
      host  = 'my_host'
      task  = 'my_task'

      listener.on_start jobid
      listener.on_node_start host
      listener.on_task_start host, task
      listener.on_task_active host, task
      listener.on_task_expire host, task
      listener.on_task_stop host, task
      listener.on_node_stop host
      listener.on_timeout
      listener.on_log host, 'message'
      listener.on_interrupted
      listener.on_stop

      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S##{Process.pid}")

      stdout.string.should == <<-OUTPUT
I, [#{timestamp}]  INFO -- : start: my_jobid
I, [#{timestamp}]  INFO -- : start node: my_host
I, [#{timestamp}]  INFO -- : start host: my_host task: my_task
I, [#{timestamp}]  INFO -- : active host: my_host task: my_task
I, [#{timestamp}]  INFO -- : expire host: my_host task: my_task
I, [#{timestamp}]  INFO -- : stop host: my_host task: my_task
I, [#{timestamp}]  INFO -- : stop node: my_host
I, [#{timestamp}]  INFO -- : timeout
I, [#{timestamp}]  INFO -- : host: my_host message
I, [#{timestamp}]  INFO -- : interrupted
I, [#{timestamp}]  INFO -- : stop
OUTPUT
    end
  end
end
