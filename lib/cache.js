const Redis = require("ioredis");

let client = null;

function getClient() {
  if (client) return client;

  const endpoint = process.env.CACHE_ENDPOINT;
  if (!endpoint) return null;

  const port = process.env.CACHE_PORT || 6379;
  const tlsConfig = process.env.CACHE_TLS === 'true' ? { tls: {} } : {};
  client = new Redis({ host: endpoint, port: Number(port), ...tlsConfig, maxRetriesPerRequest: 1, connectTimeout: 3000, retryStrategy: () => null });

  client.on("error", (err) => {
    console.error("Redis error:", err.message);
  });

  client.on("end", () => {
    client = null;
  });

  return client;
}

async function get(key) {
  const redis = getClient();
  if (!redis) return { data: null, error: false };
  try {
    const data = await redis.get(key);
    return { data: data ? JSON.parse(data) : null, error: false };
  } catch {
    return { data: null, error: true };
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
