module SimpleWorker
  class EventMonitor < AbstractListener

    attr_reader :start_time, :latest_time, :expired_tasks

    def initialize(start_time = Time.now)
      @start_time = start_time
      @latest_time = start_time
      @expired_tasks = []
      @event_tracker = {}
    end

    def on_start(jobid)
      @jobid = jobid
    end

    def on_node_start(hostname)
      @event_tracker[hostname] = @current_time
    end

    def on_node_stop(hostname)
      @event_tracker.delete(hostname)
    end

    def on_task_start(hostname, task)
      @event_tracker[hostname] = @current_time
      @event_tracker[task] = @current_time
    end

    def on_task_stop(hostname, task)
      @event_tracker[hostname] = @current_time
      @event_tracker.delete(task)
    end

    def on_task_expire(hostname, task)
      @expired_tasks << {:task => task, :hostname => hostname, :time => @current_time}
      @event_tracker.delete(task)
    end

    def done?(remaining)
      (remaining == 0) && @event_tracker.empty?
    end

    def update(meth, *args)
      @current_time = Time.now
      super(meth, *args)
    end

  end
end
