#!/bin/bash

if [ "$(uname -m)" = "arm64" ]; then
  export DOCKERFILE=Dockerfile.arm64
else
  export DOCKERFILE=Dockerfile.amd64
fi

docker-compose up --build