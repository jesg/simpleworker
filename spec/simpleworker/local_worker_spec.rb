require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe LocalWorker do
    let(:mock_process) { double(ChildProcess, :io => double('io').as_null_object) }
    let(:mock_env)     { double(Hash) }
    let(:local_worker) { LocalWorker.new }
    let(:jobid)        { 'my_jobid' }

    it 'can start local worker' do
      ChildProcess.should_receive(:build).and_return(mock_process)
      mock_process.should_receive(:environment).and_return(mock_env)
      mock_env.should_receive(:[]=).with('JOBID', jobid)
      mock_process.should_receive(:start)

      local_worker.on_start(jobid)
    end

    it 'can stop local worker' do
      ChildProcess.should_receive(:build).and_return(mock_process)
      mock_process.should_receive(:stop)

      local_worker.on_stop
    end
  end
end
