local result = {{},{}}
local active  = redis.pcall('SMEMBERS', KEYS[1])

for _, v in pairs(active) do
   local exists = tonumber(redis.pcall('EXISTS', v))
   if exists == 0 then
      table.insert(result[1], v)
      redis.pcall('SREM', KEYS[1], v)
   else
      table.insert(result[2], v)
   end
end
return result
