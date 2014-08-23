
module SimpleWorker
  class LocalWorker
    include AbstractWorker

    def initialize
      @script = 'simple-localworker'
      @env = {}
    end

    def self.create(config = {})
      worker = new
      worker.script = config['script'] if config.has_key? 'script'
      worker.cmd = config['cmd'] if config.has_key? 'cmd'
      worker.out = config['out'] if config.has_key? 'out'
      worker
    end
  end
end
