#!/usr/bin/env bash

if [[ "$#" != "1" ]]; then
  echo "Usage: ./start-server.sh [instance-folder]"
  exit 1
fi

# strip any trailing slashes (for convenience when inputting)
instance_dir="${1%/}"

# Get the save directory to make sure mount works
AltSaveDirectoryName="$(grep instance1/config/instance-opts.ini -oPe '^AltSaveDirectoryName=\K.+' || echo -n SavedArks)"
clusterid="$(grep instance1/config/server-opts.ini -oPe '^clusterid=\K.+' || echo -n "cluster1")"

save_dir="$instance_dir/$AltSaveDirectoryName"
cluster_dir="clusters/$clusterid"

echo "Save directory is $save_dir"
echo "Cluster directory is $cluster_dir"

# Make sure the directories exist and set them to 777 so the `steam` user inside the container has permission to save files there
mkdir -p "$save_dir" "$cluster_dir"
chmod 777 -R "$save_dir" "$cluster_dir"

# Start the server
INSTANCE="$instance_dir" SAVE="$AltSaveDirectoryName" CLUSTER="$clusterid" docker-compose up -d ark-ded
