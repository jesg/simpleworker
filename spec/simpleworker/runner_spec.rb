require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe Runner do
    let(:mock_worker) { double(AbstractWorker, :start => nil, :wait => nil, :stop => nil) }

    it 'can run workers' do
      mock_worker.should_receive(:start)
      mock_worker.should_receive(:wait)
      mock_worker.should_receive(:stop)

      Runner.run [mock_worker]
    end
  end
end
