local task = redis.call('LPOP', KEYS[1])
if not task then
   return nil
end

local task_key = string.format("%s:active:%s:%s:%s", ARGV[1], ARGV[2], ARGV[3], task)
redis.pcall('SADD', KEYS[2], task_key)
redis.pcall('SET',
           task_key,
           task,
           "EX", ARGV[4])
return task
