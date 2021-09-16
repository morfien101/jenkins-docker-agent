#!/bin/bash
version=0.1.1

CONTAINER_NAME="morfien101/jenkins-ssh-docker"
CONTAINER_VERSION=$version

docker build -t $CONTAINER_NAME:build .

for v  in "latest" $CONTAINER_VERSION; do
  docker tag $CONTAINER_NAME:build $CONTAINER_NAME:$v
  echo "PUSH CMD: docker push $CONTAINER_NAME:$v"
done