package example

import groovy.util.logging.Slf4j
import redis.clients.jedis.Jedis

@Slf4j
class RedisQueueWriter {
    static final String pushScript = "local len = redis.call('rpush', KEYS[1], ARGV[1]); local size = tonumber(ARGV[2]); if (len > size) then len = size; redis.call('ltrim', KEYS[1], -size, -1); end; return len;"
    String pushScriptHash
    
    String redisHost
    int redisPort
    String queue
    String queueMaxSize = '2048'

    Jedis jedis

    void setRedisServer(String host, int port) {
        redisHost = host
        redisPort = port
        jedis = new Jedis(host, port, 300)
    }

    void setRedisServer(String uri) {
        jedis = new Jedis(new URI(uri), 300)
    }

    @Override
    public void process(String item) {
        loadScript()
        try {
            // Logstash uses RPUSH to put events to redis list.
            try {
                jedis.evalsha(pushScriptHash, 1, queue, item, queueMaxSize)
            } catch(Exception jex) {
                if (jex.message.startsWith('NOSCRIPT')) {
                    jedis.eval(pushScript, 1, queue, item, queueMaxSize)
                }
                throw jex
            }
        } catch (Exception ex) {
            log.error "push event to redis failed. error: ${ex.message}"
            try {
                // make jedis reconnect next time
                jedis.disconnect()
            } catch (Exception e) {}
        }
    }
    
    void loadScript() {
        if (!pushScriptHash) {
            pushScriptHash = jedis.scriptLoad(pushScript)
        }
    }
}
