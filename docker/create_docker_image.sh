#!/bin/bash
set -e

CORE_SERVER_TAG=$1
export CORE_SERVER_TAG=$(echo "$1" | tr '/' '-')
export WORKSPACE_DIR=${2:-$(pwd)}
# CORE_SERVER_REPO="/home/runner/work/i2b2-core-server/i2b2-core-server/"

CORE_SERVER_REPO="$WORKSPACE_DIR"

cd edu.harvard.i2b2.server-common && ant clean dist war; #for push/commit  branch
cp dist/i2b2.war $CORE_SERVER_REPO/docker/configuration/customization/;
cd $CORE_SERVER_REPO/docker;
sh create_and_push_to_dockerhub.sh
