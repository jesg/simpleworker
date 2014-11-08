
module SimpleWorker
  class SshWorker < AbstractListener

    attr_reader :user, :host, :port, :dirname, :cmd

    def initialize(opts = {})
      @user    = opts[:user] || `whoami`.strip
      @host    = opts[:host] || `hostname`.strip
      @port    = opts[:port] || '22'
      @cmd     = opts[:cmd]  || 'bundle install; rake;'
      @dirname = opts[:dirname]
    end

    def on_start(jobid)
      @dirname ||= jobid
      @jobid = jobid

      sync_to_remote
      async_cmd
    end

    def on_stop
      sync_from_remote
    end

    private

    def sync_to_remote
      `rsync -a --delete -e "ssh -p #{port}" "${PWD}/" "#{user}@#{host}:~/#{dirname}"`
    end

    def sync_from_remote
      `rsync -a -e "ssh -p #{port}" "#{user}@#{host}:~/#{dirname}/" "${PWD}"`
    end

    def async_cmd
      `ssh -p #{port} "#{user}@#{host}" "/bin/bash -lc 'cd ~/#{dirname}; export JOBID=#{@jobid}; #{cmd}' </dev/null >/dev/null 2>&1 &"`
    end
  end
end
