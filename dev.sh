#!/bin/sh

# Run this script on my Mac and it will create a container and then
# go be root in it.

docker build -t pirateguillermo/clstumpy:dev --target dev .

docker run --rm -it \
 -v $(pwd):/build \
 -v /opt/mirrors:/opt/mirrors \
 -v $(pwd)/../StumpyNIO:/opt/StumpyNIO \
 -p 1081:1081 \
 -p 9191:9191 \
 -w /build pirateguillermo/clstumpy:dev bash
