
module SimpleWorker
  class LocalWorker
    include AbstractWorker

    def initialize
      @script = %W[bash #{File.expand_path(File.dirname(__FILE__))}/bash/simple-localworker]
      @env = {}
    end

    def self.create(config = {})
      worker = new
      worker.script = config['script'] if config.has_key? 'script'
      worker.cmd = config['cmd'] if config.has_key? 'cmd'
      worker
    end
  end
end
