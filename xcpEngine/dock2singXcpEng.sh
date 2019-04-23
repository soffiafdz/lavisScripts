#!/bin/bash
# Script to convert Docker image into Singularity 
# xcpEngine docker image
#old version of singularity that exports images compatible with LAVIS

docker run -v /var/run/docker.sock:/var/run/docker.sock \
	-v /home/soffiafdz/Documents/lavisScripts:/output --privileged \
	-t --rm singularityware/docker2singularity:v2.3 pennbbl/xcpengine
