
module SimpleWorker::AbstractWorker

  attr_accessor :script

  def start
    if script.kind_of? Array
      @process = ChildProcess.build *script
    else
      @process = ChildProcess.build script
    end

    @process.io.inherit!

    env.each do |key, value|
      @process.environment[key] = value
    end

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
end
