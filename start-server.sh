#!/usr/bin/env bash

instance_dir="$1"

# Get the save directory to make sure mount works
AltSaveDirectoryName="$(grep instance1/config/instance-opts.ini -oPe '^AltSaveDirectoryName=\K.+' || echo -n SavedArks)"
clusterid="$(grep instance1/config/server-opts.ini -oPe '^clusterid=\K.+' || echo -n)"

# Start the server
INSTANCE="$instance_dir" SAVE="$AltSaveDirectoryName" CLUSTER="$clusterid" docker-compose up -d ark-ded
