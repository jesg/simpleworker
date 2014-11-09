
module SimpleWorker

  #
  # SshWorker.new(opts)
  #
  # where 'opts' is a Hash of options:
  #
  #  :user    => String name of user on remote host (default: `whoami`)
  #  :host    => String name of remote host (default: `hostname`)
  #  :port    => String port to connect on the remote host (default: 22)
  #  :cmd     => String bash string to execute on the remote host in the users login shell, in the remote 'dirname', and with the JOBID environment variable set to the current jobid, (default: `bundle install; rake;`)
  #  :dirname => String remote directory in the users home directory (default: dynamic jobid)
  class SshWorker < AbstractListener

    attr_reader :user, :host, :port, :dirname, :cmd

    def initialize(opts = {})
      @user    = opts[:user] || `whoami`.strip
      @host    = opts[:host] || `hostname`.strip
      @port    = opts[:port] || '22'
      @cmd     = opts[:cmd]  || 'bundle install; rake;'
      @dirname = opts[:dirname]
    end

    # Destructive rsync to remote and start a process in the background on the remote server.
    def on_start(jobid)
      @dirname ||= jobid
      @jobid = jobid

      sync_to_remote
      async_cmd
    end

    # Rsync from remote.
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
