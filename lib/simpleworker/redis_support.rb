
module SimpleWorker
  module RedisSupport

    attr_reader :namespace, :jobid

    private

    def tasks_key
      @tasks_key ||= "#{namespace}:tasks:#{jobid}"
    end

    def log_key
      @log_key ||= "#{namespace}:log:#{jobid}"
    end

    def active_tasks_key
      @active_tasks_key ||= "#{namespace}:active:#{jobid}"
    end

    def config_key
      @config_key ||= "#{namespace}:config:#{jobid}"
    end

    def load_lua_scripts
      path_to_lua_scripts = File.expand_path("scripts/", File.dirname(__FILE__))
      ['lpopall', 'expired_tasks', 'reliable_queue'].each do |name|
        sha = @redis.script(:load, IO.read("#{path_to_lua_scripts}/#{name}.lua"))
        instance_variable_set("@#{name}_sha", sha)
      end
    end
  end
end
