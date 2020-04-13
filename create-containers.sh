#!/bin/bash
docker network create --driver bridge fakecam

docker create \
  --name=bodypix \
  --network=fakecam \
  -p 9000:9000 \
  --device=/dev/kfd \
  --device=/dev/dri \
  --ipc=host \
  --shm-size 16G \
  --group-add video \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  bodypix

docker create \
  --name=fakecam \
  --network=fakecam \
  --env VIDEO_DEV_REAL='/dev/video1' \
  --env VIDEO_DEV_LOOPBACK='/dev/video2' \
  -u "$(id -u):$(getent group video | cut -d: -f3)" \
  $(find /dev -name 'video*' -printf "--device %p ") \
  fakecam
