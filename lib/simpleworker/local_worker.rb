
module SimpleWorker
  class LocalWorker
    include AbstractWorker

    DEFAULT_ENV = {
      'RUBY_TASK' => 'rake'
    }

    def initialize(cmd = nil)
      @script = 'simple-localworker'
      env = cmd ? {'RUBY_TASK' => cmd.join(' ')} : {}
      @env = DEFAULT_ENV.dup.merge(env)
    end
  end
end
