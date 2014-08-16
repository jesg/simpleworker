
class SimpleWorker::Runner

  def initialize(workers)
    @workers = workers
  end

  def self.run(workers)
    new(workers).run
  end

  def run
    start
    process
    stop
  rescue Interrupt
    stop
  rescue StandardError
    stop
    raise
  end

  private

  def start
    @workers.each &:start
  end

  def process
    @workers.each &:wait
  end

  def stop
    @workers.each &:stop
  end
end

