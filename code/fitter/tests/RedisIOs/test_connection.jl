#########
@info "RedisIOs.test_connection -- PING - PONG"
@test RedisIOs.test_connection(Parameters.LOCAL_REDIS_HOST, Parameters.LOCAL_REDIS_PORT, Parameters.LOCAL_REDIS_PASSWORD) == true
#########