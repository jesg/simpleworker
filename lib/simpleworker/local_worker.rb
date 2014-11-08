
module SimpleWorker
  class LocalWorker < AbstractListener

    def initialize(cmd = '/bin/bash -l bundle exec rake')
      @process = ChildProcess.build(cmd)
    end

    def on_start(jobid)
      @process.environment['JOBID'] = jobid
      @process.start
    end

    def on_stop
      @process.stop
    end
  end
end
