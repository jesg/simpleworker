
module SimpleWorker::AbstractWorker

  attr_accessor :script, :cmd

  def start
    if script.kind_of? Array
      @process = ChildProcess.build *script
    else
      @process = ChildProcess.build script
    end

    @process.io.inherit!

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
