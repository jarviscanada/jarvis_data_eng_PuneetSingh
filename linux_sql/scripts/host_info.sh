#!/bin/bash
# Usage: bash host_info.sh psql_host psql_port db_name psql_user psql_password
# Example: bash host_info.sh localhost 5432 host_agent postgres mypassword

# ---- Step 1: Parse arguments ----
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "Usage: $0 psql_host psql_port db_name psql_user psql_password"
    exit 1
fi

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# ---- Step 2: Collect host info ----
hostname=$(hostname -f)
lscpu_out=$(lscpu)

cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\)/ {print $2}' | xargs)
cpu_number=${cpu_number:-0}  # default 0 if empty

cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture/ {print $2}' | xargs)
cpu_architecture=${cpu_architecture:-unknown}

cpu_model=$(echo "$lscpu_out" | awk -F: '/^Model name/ {print $2}' | xargs)
cpu_model=${cpu_model:-unknown}

cpu_mhz=$(echo "$lscpu_out" | awk -F: '/^CPU MHz/ {print $2}' | xargs)
cpu_mhz=${cpu_mhz:-0}

l2_cache=$(echo "$lscpu_out" | awk -F: '/^L2 cache/ {gsub("[^0-9]","",$2); print $2}' | xargs)
l2_cache=${l2_cache:-0}

# Total memory in MB (free + buff + cache)
total_mem=$(vmstat --unit M | awk 'NR==3 {print $4+$5+$6}' | xargs)
total_mem=${total_mem:-0}

# Current UTC timestamp
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# ---- Step 3: Build INSERT statement ----
insert_stmt="INSERT INTO host_info(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp)
SELECT '$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem, '$timestamp'
WHERE NOT EXISTS (SELECT 1 FROM host_info WHERE hostname='$hostname');"

# ---- Step 4: Execute INSERT ----
export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?

