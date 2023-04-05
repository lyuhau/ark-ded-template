#!/usr/bin/env bash

if [[ "$#" == "0" ]]; then
  if [[ -f ".previous_command" ]]; then
    readarray -t a < ".previous_command"
    set -- "${a[@]}"
  fi
fi

if [[ "$#" != "1" ]]; then
  echo "Usage: ./start-server.sh [instance-folder]"
  exit 1
fi

printf '%s\n' "$@" >.previous_command

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
INSTANCE="$instance_dir" SAVE="$AltSaveDirectoryName" CLUSTER="$clusterid" docker compose config --format json \
| jq -r '.services["ark-ded"].volumes[] | select(.read_only | not).source' \
| while read volume; do
  mkdir -p "$volume"
  chown 1000:1000 -R "$volume"
done

# Start the server
INSTANCE="$instance_dir" SAVE="$AltSaveDirectoryName" CLUSTER="$clusterid" docker-compose up -d ark-ded
