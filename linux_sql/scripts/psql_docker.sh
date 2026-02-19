#!/bin/sh
set -eu

# Capture CLI arguments
cmd=${1:-}
db_username=${2:-}
db_password=${3:-}

container_name="jrvs-psql"
volume_name="pgdata"

# Start docker (|| means "if left fails, run right")
# - If docker is NOT active, start it.
# - If docker is already active, do nothing.
if ! sudo systemctl is-active --quiet docker; then
  sudo systemctl start docker
fi

# Check if container exists
if docker container inspect "$container_name" >/dev/null 2>&1; then
  container_exists=1
else
  container_exists=0
fi

case "$cmd" in
  create)
    # Check # of CLI arguments
    if [ $# -ne 3 ]; then
      echo "Usage: $0 create <db_username> <db_password>"
      exit 1
    fi

    # Check if the container is already created
    if [ "$container_exists" -eq 1 ]; then
      echo "Container $container_name already exists"
      exit 1
    fi

    # Create volume (persistent storage)
    docker volume create "$volume_name" >/dev/null

    # Create and start container
    docker run -d \
      --name "$container_name" \
      -e POSTGRES_USER="$db_username" \
      -e POSTGRES_PASSWORD="$db_password" \
      -v "$volume_name":/var/lib/postgresql/data \
      -p 5432:5432 \
      postgres:9.6-alpine

    # Print success message
    echo "Postgres container $container_name created and started."
    echo "Port: 5432, Volume: $volume_name"
    ;;

  start|stop)
    # Exit 1 if container has not been created
    if [ "$container_exists" -eq 0 ]; then
      echo "Container $container_name does not exist. Run: $0 create <db_username> <db_password>"
      exit 1
    fi

    # Start or stop the container
    docker container "$cmd" "$container_name"
    echo "Container $container_name $cmd successful."
    ;;

  *)
    echo "Illegal command"
    echo "Usage:"
    echo "  $0 create <db_username> <db_password>"
    echo "  $0 start"
    echo "  $0 stop"
    exit 1
    ;;
esac
