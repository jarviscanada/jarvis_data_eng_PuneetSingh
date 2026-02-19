

-- Switch to host_agent database
\c host_agent;

-- Fail fast if not connected to the expected database (PostgreSQL doesn't support `USE dbname`)
DO $$
BEGIN
  IF current_database() <> 'host_agent' THEN
    RAISE EXCEPTION
      'You must connect to host_agent database before running this script. Example: psql -d host_agent -f linux_sql/scripts/sql/ddl.sql';
\c host_agent 
END IF;
END
$$;

-- Create host_info table if it does not exist
CREATE TABLE IF NOT EXISTS host_info
(
    id               SERIAL PRIMARY KEY,
    hostname         VARCHAR NOT NULL UNIQUE,
    cpu_number       INT2 NOT NULL,
    cpu_architecture VARCHAR NOT NULL,
    cpu_model        VARCHAR NOT NULL,
    cpu_mhz          FLOAT8 NOT NULL,
    l2_cache         INT4 NOT NULL,
    "timestamp"      TIMESTAMP,
    total_mem        INT4
);

-- Create host_usage table if it does not exist
CREATE TABLE IF NOT EXISTS host_usage
(
    "timestamp"    TIMESTAMP NOT NULL,
    host_id        INT NOT NULL,
    memory_free    INT4 NOT NULL,
    cpu_idle       INT2 NOT NULL,
    cpu_kernel     INT2 NOT NULL,
    disk_io        INT4 NOT NULL,
    disk_available INT4 NOT NULL,
    CONSTRAINT host_usage_host_info_fk FOREIGN KEY (host_id) REFERENCES host_info(id)
);

