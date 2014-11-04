local result = {}
local length = tonumber(redis.pcall('LLEN', KEYS[1]))
for i = 1, length do
   local val = redis.pcall('LPOP',KEYS[1])
   if val then
      table.insert(result,val)
   end
end
return result
