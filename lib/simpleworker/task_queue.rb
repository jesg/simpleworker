
module SimpleWorker
  class TaskQueue
    include RedisSupport

    DEFAULT_OPTIONS = {
      :task_timeout => 30,
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

    def each_task
      until pop.nil?
        fire_task_start @current_task
        yield @current_task
        fire_task_stop @current_task
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
