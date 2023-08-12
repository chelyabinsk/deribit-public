# Deribit Market Data Dashboard

Welcome to the Deribit Market Data Dashboard repository! This README provides a guide on running tests for the project within a Docker container.

## Running Julia Tests in Docker

1. Make sure you have Docker installed on your system. If not, you can download and install it from [Docker's official website](https://www.docker.com/get-started).

2. Clone this repository to your local machine:
   ```sh
   git clone https://github.com/chelyabinsk/deribit-public.git
   ```
3. Navigate to the project directory:
   ```sh
   cd deribit-public
   ```
4. Build the Docker image:
   ```sh
   docker build -t deribit-dashboard .
   ```
5. Start Redis server
   ```sh
   docker run --rm --name redislocal --network local-dev -d -p 63001:6379 redis redis-server --requirepass "REDIS_PASSWORD"
   ```
6. Run the Docker container and execute Julia tests using the run_tests.jl file:
   ```sh
   docker run -it --net local-dev -p 80:5000 --rm -v ./code/:/app/code --log-driver json-file --log-opt max-size=100m --log-opt max-file=10 --log-opt mode=non-blocking --log-opt max-buffer-size=16m deribit-dashboard;
   cd code/fitter; julia run_tests.jl
   ```

## Running the dashboard

Make sure to run the tests first.

1. Start docker and run flask dashboard
   ```sh
   docker run -it --net local-dev -p 80:5000 --rm -v ./code/:/app/code --log-driver json-file --log-opt max-size=100m --log-opt max-file=10 --log-opt mode=non-blocking --log-opt max-buffer-size=16m deribit-dashboard;
   cd code/dashboard;
   python3 -m flask run --host=0.0.0.0
   ```
2. Open browser and navigate to the dashboard page at ```localhost```
