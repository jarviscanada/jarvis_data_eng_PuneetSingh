#!/bin/bash

# Usage: bash scripts/host_usage.sh psql_host psql_port db_name psql_user psql_password
# Example: bash scripts/host_usage.sh localhost 5432 host_agent postgres mypassword

# ---- Step 1: Parse arguments ----
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# ---- Step 2: Collect host usage ----
hostname=$(hostname -f)
vmstat_out=$(vmstat --unit M)

memory_free=$(echo "$vmstat_out" | awk 'NR==3 {print $4}' | xargs)
cpu_idle=$(echo "$vmstat_out" | awk 'NR==3 {print $15}' | xargs)
cpu_kernel=$(echo "$vmstat_out" | awk 'NR==3 {print $14}' | xargs)
disk_io=$(vmstat -d | tail -1 | awk '{print $10}' | xargs)
disk_available=$(df -BM / | tail -1 | awk '{gsub("M",""); print $4}')

timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# ---- Step 3: Build INSERT statement ----
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# ---- Step 4: Execute INSERT ----
export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"

exit $?

