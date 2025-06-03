#!/bin/sh

echo BUILDING:
set -x
docker build --progress plain -t university101:v006 "$@" .
