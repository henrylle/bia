const Redis = require("ioredis");

let client = null;

function getClient() {
  if (client) return client;

  const endpoint = process.env.CACHE_ENDPOINT;
  if (!endpoint) return null;

  const port = process.env.CACHE_PORT || 6379;
  client = new Redis({ host: endpoint, port: Number(port) });

  client.on("error", (err) => {
    console.error("Redis error:", err.message);
  });

  return client;
}

async function get(key) {
  const redis = getClient();
  if (!redis) return null;
  try {
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  } catch {
    return null;
  }
}

async function set(key, value, ttl = Number(process.env.CACHE_TTL) || 60) {
  const redis = getClient();
  if (!redis) return;
  try {
    await redis.set(key, JSON.stringify(value), "EX", ttl);
  } catch {}
}

async function del(key) {
  const redis = getClient();
  if (!redis) return;
  try {
    await redis.del(key);
  } catch {}
}

async function ttl(key) {
  const redis = getClient();
  if (!redis) return null;
  try {
    const remaining = await redis.ttl(key);
    return remaining > 0 ? remaining : null;
  } catch {
    return null;
  }
}

module.exports = { get, set, del, ttl };
