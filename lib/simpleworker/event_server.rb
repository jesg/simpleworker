module SimpleWorker
  class EventServer
    include Observable
    include RedisSupport

    def initialize(redis, namespace, jobid)
      @redis     = redis
      @namespace = namespace
      @jobid     = jobid
      load_lua_scripts
    end

    def pull_events
      log, processing, remaining = @redis.multi do
        @redis.evalsha @lpopall_sha, [log_key]
        @redis.evalsha @expired_tasks_sha, [active_tasks_key]
        @redis.llen tasks_key
      end

      log.map { |str| JSON.parse(str) }.each do |event|
        fire(*event)
      end

      processing[0].each do |key|
        hostname, task = parse_active_task_key(key)
        fire('on_task_expire', hostname, task)
      end

      processing[1].each do |key|
        hostname, task = parse_active_task_key(key)
        fire('on_task_active', hostname, task)
      end

      remaining
    end

    private

    def parse_active_task_key(str)
      str.split(':').slice(3, 4)
    end

    def fire(*args)
      changed
      notify_observers *args
    end
  end
end
