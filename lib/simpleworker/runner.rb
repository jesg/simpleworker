
module SimpleWorker
  class Runner
    include RedisSupport
    include Observable

    attr_reader :jobid

    DEFAULT_OPTIONS = {
      :timeout   => 30,
      :interval  => 5,
      :namespace => 'simpleworker'}

    def initialize(redis, tasks, opts = {})
      opts = DEFAULT_OPTIONS.dup.merge(opts)

      @redis = redis
      @jobid = SecureRandom.hex(6)
      @namespace = opts[:namespace]
      @timeout = opts[:timeout]
      @interval = opts[:interval]

      load_lua_scripts
      @redis.rpush(tasks_key, tasks)

      listeners = Array(opts[:notify])
      @event_server = EventServer.new(redis, namespace, jobid)
      @event_monitor = EventMonitor.new
      listeners << @event_monitor

      listeners.each do |listener|
        add_observer listener
        @event_server.add_observer listener
      end
    end

    def self.run(redis, tasks, opts = {})
      new(redis, tasks, opts).run
    end

    def run
      start
      process
      stop
    rescue Interrupt
      fire 'on_interrupted'
      stop
    rescue StandardError => e
      fire 'on_interrupted'
      stop
      raise e
    end

    private

    def start
      fire('on_start', @jobid)
    end

    def process
      remaining_tasks = @event_server.pull_events

      until @event_monitor.done? remaining_tasks
        sleep @interval

        remaining_tasks = @event_server.pull_events
        current_time = Time.now
        if (current_time - @event_monitor.latest_time) > @timeout
          fire('on_timeout')
          break
        end
      end
    end

    def stop
      fire('on_stop')

      @redis.multi do
        @redis.del tasks_key
        @redis.del active_tasks_key
        @redis.del log_key
      end
    end

    private

    def fire(*args)
      changed
      notify_observers *args
    end
  end
end
