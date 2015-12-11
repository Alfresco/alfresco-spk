#!/bin/bash

#Download pre-defined Docker Images
echo "Pulling Docker images..."
docker pull centos
docker pull orchardup/mysql:latest

# Not used ATM
# docker pull crosbymichael/skydns:latest
# docker pull crosbymichael/skydock:latest
# docker pull dockerfile/haproxy:latest
