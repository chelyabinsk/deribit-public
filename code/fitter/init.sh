# Create a custom local docker network
docker network create local-dev

# Start Redis
docker run --rm --name redislocal --network local-dev -d -p 63001:6379 redis redis-server --requirepass "REDIS_PASSWORD"
