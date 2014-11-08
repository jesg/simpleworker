
module SimpleWorker
  class RetryListener < AbstractListener
    include RedisSupport

    attr_reader :max_retries, :tasks

    def initialize(redis, max_retries, namespace, jobid)
      @redis       = redis
      @max_retries = max_retries
      @namespace   = namespace
      @jobid       = jobid
      @tracker     = {}
      @tasks       = []
    end

    def on_task_expire(hostname, task)
      # warning nil converted to 0
      count = @tracker[task].to_i

      if count < max_retries
        fire_retry task
        @tracker[task] = (count + 1)
        tasks << task
      end
    end

    private

    def fire_retry(task)
      @redis.rpush(tasks_key, task)
    end
  end
end
