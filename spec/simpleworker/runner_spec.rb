require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe Runner do
    let(:mock_worker) { double(AbstractWorker, :start => nil, :wait => nil, :stop => nil) }

    it 'can run workers' do
      mock_worker.should_receive(:start)
      mock_worker.should_receive(:cmd=).with('cuke')
      mock_worker.should_receive(:wait)
      mock_worker.should_receive(:stop)
      IO.should_receive(:read).with('simpleworker.yml').and_return('hi')
      YAML.should_receive(:load).with('hi').and_return({'workers' => [{'type' => 'ssh'}]})
      SshWorker.should_receive(:create).and_return(mock_worker)

      Runner.run 'cuke'
    end
  end
end
