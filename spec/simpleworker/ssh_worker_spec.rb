require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe SshWorker do
    let(:mock_env)     { double(Hash) }
    let(:mock_process) { double(ChildProcess, :start => nil, :stop => nil, :wait => nil, :io => double('io').as_null_object, :environment => mock_env) }

    it 'can start ssh worker with defaults' do
      ChildProcess.should_receive(:build).with('ssh-remoteworker').and_return(mock_process)
      mock_process.should_receive(:start)
      mock_env.should_receive(:[]=).once.with('RUBY_TASK', 'rake')
      mock_env.should_receive(:[]=).once.with('user', `whoami`)
      mock_env.should_receive(:[]=).once.with('host', 'localhost')
      mock_env.should_receive(:[]=).once.with('directory', Dir.pwd)

      SshWorker.new.start
    end

    it 'can start ssh worker with customization' do
      ChildProcess.should_receive(:build).with('ssh-remoteworker').and_return(mock_process)
      mock_process.should_receive(:start)
      mock_env.should_receive(:[]=).once.with('RUBY_TASK', 'cuke')
      mock_env.should_receive(:[]=).once.with('user', 'bob')
      mock_env.should_receive(:[]=).once.with('host', 'foo')
      mock_env.should_receive(:[]=).once.with('directory', 'bar')

      mock_process.should_receive(:wait)
      mock_process.should_receive(:stop)

      worker = SshWorker.new %w[cuke]
      worker.user = 'bob'
      worker.host = 'foo'
      worker.directory = 'bar'
      worker.start
      worker.wait
      worker.stop
    end
  end
end

