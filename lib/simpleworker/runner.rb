
module SimpleWorker
  class Runner
    include RedisSupport
    include Observable

    DEFAULT_OPTIONS = {
      :timeout => 30,
      :interval => 5,
      :namespace => 'simpleworker'}

    def initialize(redis, tasks, opts = {})
      opts = DEFAULT_OPTIONS.dup.merge(opts)

      @redis = redis
      @jobid = SecureRandom.hex(6)
      @namespace = opts[:namespace]
      @redis.rpush(tasks_key, tasks)
      @event_server = EventServer.new(redis, namespace, jobid)
      @event_monitor = EventMonitor.new
      add_observer(@event_monitor)
      @event_server.add_observer(@event_monitor)
      @timeout = opts[:timeout]
      @interval = opts[:interval]
    end

    def self.run
      new.load.run
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
