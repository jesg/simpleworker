
module SimpleWorker
  class SshWorker
    include AbstractWorker

    attr_accessor :directory, :user, :host

    def initialize
      @script = %W[bash #{File.expand_path(File.dirname(__FILE__))}/bash/ssh-remoteworker]
      @env = {}
    end

    def self.create(config = {})
      worker = new
      worker.script = config['script'] if config.has_key? 'script'
      worker.cmd = config['cmd'] if config.has_key? 'cmd'
      worker.user = config['user'] if config.has_key? 'user'
      worker.host = config['host'] if config.has_key? 'host'
      worker.directory = config['directory'] if config.has_key? 'directory'
      worker
    end

    private

    def set_process_env
      env['user'] = user || `whoami`
      env['host'] = host || 'localhost'
      env['directory'] = directory || Dir.pwd

      super
    end
  end
end
