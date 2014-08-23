require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe LocalWorker do
    let(:mock_env)     { double(Hash) }
    let(:mock_process) { double(ChildProcess, :start => nil, :stop => nil, :wait => nil, :io => double('io').as_null_object, :environment => mock_env) }

    it 'can start local worker with defaults' do
      ChildProcess.should_receive(:build).with('bash', end_with('simple-localworker')).and_return(mock_process)
      mock_process.should_receive(:start)
      mock_env.should_receive(:[]=).with('cmd', 'rake')

      worker = LocalWorker.new
      worker.cmd = 'rake'
      worker.start
    end

    it 'can start local worker with customization' do
      ChildProcess.should_receive(:build).with('bash', end_with('simple-localworker')).and_return(mock_process)
      mock_process.should_receive(:start)
      mock_env.should_receive(:[]=).with('cmd', 'cuke')
      mock_process.should_receive(:wait)
      mock_process.should_receive(:stop)

      worker = LocalWorker.new
      worker.cmd = 'cuke'
      worker.start
      worker.wait
      worker.stop
    end
  end
end

