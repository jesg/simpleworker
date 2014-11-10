
module SimpleWorker

  # TaskQueue.new(redis, hostname, jobid, opts)
  #
  # where hostname is the machines hostname or a unique identifier
  # and 'opts' is a Hash of options:
  #
  #   :namespace    => String prefix to keys in redis used by SimpleWorker (default: simpleworker)
  #   :task_timeout => Fixnum time after which a task expires, this should be > timout set in Runner (default: 10 seconds)
  class TaskQueue
    include RedisSupport

    DEFAULT_OPTIONS = {
      :task_timeout => 10,
      :namespace    => 'simpleworker'
    }

    def initialize(redis, hostname, jobid, opts = {})
      opts               = DEFAULT_OPTIONS.dup.merge(opts)
      @redis             = redis
      @namespace         = opts[:namespace]
      @task_timeout      = opts[:task_timeout]
      @jobid             = jobid
      @hostname          = hostname
      @active_key_prefix = "#{active_tasks_key}:#{@hostname}"
      load_lua_scripts
    end

    def fire_start
      push_to_log('on_node_start', @hostname)
    end

    def fire_stop
      push_to_log('on_node_stop', @hostname)
    end

    def fire_task_start(task)
      push_to_log('on_task_start', @hostname, task)
    end

    def fire_task_stop(task)
      push_to_log('on_task_stop', @hostname, task)
    end

    def expire_current_task
      @redis.del "#{@active_key_prefix}:#{@current_task}" if @current_task
      @current_task = nil
    end

    def each_task
      until pop.nil?
        local_task = @current_task
        fire_task_start local_task
        yield local_task
        fire_task_stop local_task
      end
    end

    def pop
      @redis.srem(active_tasks_key, "#{@active_key_prefix}:#{@current_task}") if @current_task
      @current_task = @redis.evalsha(@reliable_queue_sha,
                                     :keys => [tasks_key, active_tasks_key],
                                     :argv => [namespace, jobid, @hostname, @task_timeout])
      @current_task
    end

    private

    def push_to_log(*args)
      @redis.rpush(log_key, args.to_json)
    end
  end
end
