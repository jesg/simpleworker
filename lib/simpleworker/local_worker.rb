
module SimpleWorker
  class LocalWorker
    include AbstractWorker

    DEFAULT_ENV = {
      'RUBY_TASK' => 'rake'
    }

    def initialize(*args)
      @script = 'simple-localworker'
      env = args.empty? ? {} : {'RUBY_TASK' => args.join(' ')}
      @env = DEFAULT_ENV.dup.merge(env)
    end
  end
end
