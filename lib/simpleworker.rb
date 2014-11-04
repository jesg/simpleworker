
require 'childprocess'
require 'yaml'
require 'redis'
require 'observer'
require 'json'

module SimpleWorker
end

require 'simpleworker/runner'
require 'simpleworker/abstract_worker'
require 'simpleworker/local_worker'
require 'simpleworker/ssh_worker'
require 'simpleworker/abstract_listener'
require 'simpleworker/event_monitor'
require 'simpleworker/redis_support'
require 'simpleworker/event_server'
