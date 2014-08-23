
module SimpleWorker::AbstractWorker

  attr_accessor :script, :cmd, :out

  def start
    if script.kind_of? Array
      @process = ChildProcess.build *script
    else
      @process = ChildProcess.build script
    end

    if out
      @process.io.stderr = @process.io.stdout = File.open(out, 'w')
    end

    set_process_env

    @process.start
  end

  def wait
    @process.wait
  end

  def stop
    @process.stop
  end

  def env
    @env
  end

  private

  def set_process_env
    env['cmd'] ||= cmd

    env.each do |key, value|
      @process.environment[key] = value
    end
  end

end
