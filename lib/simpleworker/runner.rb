
module SimpleWorker
  class Runner

    def initialize
      @workers = []
    end

    def self.run(cmd = 'rake')
      new.load.run(cmd)
    end

    def self.load(config = 'simpleworker.yml')
      new.load(config)
    end

    def load(config = 'simpleworker.yml')
      data = YAML.load( IO.read(config) )
      data['workers'].each do |config|
        case config['type']
        when 'ssh'
          @workers << SshWorker.create(config)
        else
          @workers << LocalWorker.create(config)
        end
      end

      self
    end

    def run(cmd = 'rake')
      @workers.each do |worker|
        worker.cmd = cmd
      end
      start
      process
      stop
    rescue Interrupt
      stop
    rescue StandardError => e
      stop
      raise e
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
end
