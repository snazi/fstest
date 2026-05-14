-- KEYS:
-- 1: stockKey
-- 2: buyersKey
-- 3: attemptKey
-- 4: userResultKey
-- ARGV:
-- 1: nowMs
-- 2: startAtMs
-- 3: endAtMs
-- 4: userId
-- 5: purchaseId
-- 6: idempotencyTtlSec

local existing = redis.call('GET', KEYS[3])
if existing then
  local code, remaining, pid, decidedAt = string.match(existing, '([^|]+)|([^|]+)|([^|]*)|(.+)')
  return { tonumber(code), tonumber(remaining), pid, decidedAt }
end

local nowMs = tonumber(ARGV[1])
local startAtMs = tonumber(ARGV[2])
local endAtMs = tonumber(ARGV[3])
local userId = ARGV[4]
local purchaseId = ARGV[5]
local ttl = tonumber(ARGV[6])
local decidedAt = tostring(nowMs)

local code = 0
local pid = ''

if nowMs < startAtMs then
  code = 1
elseif nowMs > endAtMs then
  code = 2
elseif redis.call('SISMEMBER', KEYS[2], userId) == 1 then
  code = 3
else
  local stock = tonumber(redis.call('GET', KEYS[1]) or '0')
  if stock <= 0 then
    code = 4
  else
    code = 5
    redis.call('DECR', KEYS[1])
    redis.call('SADD', KEYS[2], userId)
    pid = purchaseId
    redis.call('SET', KEYS[4], 'SUCCESS|' .. pid .. '|' .. decidedAt)
  end
end

local remaining = tonumber(redis.call('GET', KEYS[1]) or '0')
redis.call('SETEX', KEYS[3], ttl, tostring(code) .. '|' .. tostring(remaining) .. '|' .. pid .. '|' .. decidedAt)

return { code, remaining, pid, decidedAt }
