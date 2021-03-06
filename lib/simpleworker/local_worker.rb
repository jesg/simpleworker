
module SimpleWorker
  class LocalWorker < AbstractListener

    DEFAULT_CMD = ['/bin/bash', '-l', 'bundle', 'exec', 'rake']

    def initialize(*args)
      cmd = args
      cmd = DEFAULT_CMD if cmd.empty?
      @process = ChildProcess.build(*cmd)
      @process.io.inherit!
    end

    # Start a subprocess with the environment variable 'JOBID' set to the current jobid.
    #
    def on_start(jobid)
      @process.environment['JOBID'] = jobid
      @process.start
    end

    def on_stop
      @process.stop
    end
  end
end
