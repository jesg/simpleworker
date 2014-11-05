module SimpleWorker
  class AbstractListener

    def on_start(jobid)
    end

    def on_stop
    end

    def on_node_start(hostname)
    end

    def on_node_stop(hostname)
    end

    def on_task_start(hostname, task)
    end

    def on_task_active(hostname, task)
    end

    def on_task_stop(hostname, task)
    end

    def on_task_expire(hostname, task)
    end

    def on_log(hostname, msg)
    end

    def on_interrupted
    end

    def on_timeout
    end

    def update(meth, *args)
      __send__(meth, *args)
    end
  end
end
