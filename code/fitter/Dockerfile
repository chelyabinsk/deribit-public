# syntax=docker/dockerfile:1

FROM ubuntu:latest


RUN apt-get update -y; apt-get install python3 python3-pip wget nano screen -y;

WORKDIR /app
RUN useradd -m john; chown -R john:john /app; chown -R john:john /home/john; chown -R john:john /usr/local

USER john

# Install Python
COPY requirements.txt requirements.txt
COPY requirements.jl requirements.jl
RUN pip3 install -r requirements.txt

# Install Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.0-linux-x86_64.tar.gz; tar zxvf julia-1.9.0-linux-x86_64.tar.gz -C /home/john/; rm julia-1.9.0-linux-x86_64.tar.gz
ENV PATH="$PATH:/home/john/julia-1.9.0/bin"
RUN julia requirements.jl

