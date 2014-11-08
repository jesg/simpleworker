
module SimpleWorker
  class LoggingListener < AbstractListener

    TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    def initialize(io = STDOUT)
      @io = io
    end

    def on_start(jobid)
      log.info "start: #{jobid}"
    end

    def on_stop
      log.info "stop"
    end

    def on_node_start(hostname)
      log.info "start node: #{hostname}"
    end

    def on_node_stop(hostname)
      log.info "stop node: #{hostname}"
    end

    def on_task_start(hostname, task)
      log.info "start host: #{hostname} task: #{task}"
    end

    def on_task_active(hostname, task)
      log.info "active host: #{hostname} task: #{task}"
    end

    def on_task_stop(hostname, task)
      log.info "stop host: #{hostname} task: #{task}"
    end

    def on_task_expire(hostname, task)
      log.info "expire host: #{hostname} task: #{task}"
    end

    def on_log(hostname, msg)
      log.info "host: #{hostname} #{msg}"
    end

    def on_interrupted
      log.info "interrupted"
    end

    def on_timeout
      log.info "timeout"
    end

    private

    def log
      @log ||= (
        log = ::Logger.new @io
        log.datetime_format = TIME_FORMAT
        log
      )
    end
  end
end
