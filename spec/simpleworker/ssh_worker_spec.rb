require File.expand_path('../../spec_helper.rb', __FILE__)

module SimpleWorker
  describe SshWorker do
    let(:mock_process) { double(ChildProcess, :io => double('io').as_null_object) }
    let(:jobid)        { 'my_jobid' }
    let(:ssh_worker) { SshWorker.new(
      :user    => 'jesg',
      :host    => 'localhost',
      :port    => '22',
      :cmd     => 'my_cmd',
      :dirname => 'work_dir')
    }

    it 'can start ssh worker' do
      expected_sync_cmd ='rsync -a --delete -e "ssh -p 22" "${PWD}/" "jesg@localhost:~/work_dir"'
      expected_async_cmd = %q[ssh -p 22 "jesg@localhost" "/bin/bash -lc 'cd ~/work_dir; export JOBID=my_jobid; my_cmd' </dev/null >/dev/null 2>&1 &"]
      Kernel.stub('`')
      ssh_worker.should_receive(:sync_to_remote)
      ssh_worker.should_receive(:async_cmd)

      ssh_worker.on_start(jobid)
    end

    it 'can stop ssh worker' do
      Kernel.stub('`')
      ssh_worker.should_receive(:sync_from_remote)

      ssh_worker.on_stop
    end
  end
end
