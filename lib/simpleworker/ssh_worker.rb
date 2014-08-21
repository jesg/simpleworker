
module SimpleWorker
  class SshWorker
    include AbstractWorker

    DEFAULT_ENV = {
      'RUBY_TASK' => 'rake'
    }

    attr_accessor :directory, :user, :host

    def initialize(cmd = nil)
      @script = 'ssh-remoteworker'
      env = cmd ? {'RUBY_TASK' => cmd.join(' ')} : {}
      @env = DEFAULT_ENV.dup.merge(env)
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
