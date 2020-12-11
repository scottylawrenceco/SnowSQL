USE ROLE SYSADMIN;

/* Create a unique database for Stitch to deliver data to. */

CREATE DATABASE STITCH_DATA;

/* Create a warehouse with a 30 second suspend time. These settings
are for the optimal cost savings during a historic load. Stitch basic
plans cap at 6GB load cycles every 10 minutes, so it's best to key suspends fast
and keep comput capacity small. Enterprise accounts should use larger machines
with a higher cap. */
CREATE WAREHOUSE STITCH_DATA_LOADER_XS 
WITH WAREHOUSE_SIZE = 'XSMALL' 
WAREHOUSE_TYPE = 'STANDARD' 
AUTO_SUSPEND = 30 
AUTO_RESUME = TRUE 
MIN_CLUSTER_COUNT = 1 
MAX_CLUSTER_COUNT = 2 
SCALING_POLICY = 'STANDARD';

/* Create roles and users for stitch. Apply a network policy to only allow 
Stitch's IP addresses to be whitelisted from this user. */

USE ROLE ACCOUNTADMIN;

CREATE ROLE DATA_SERVICE COMMENT = 'Role for Stitch Data ETL data services.';

GRANT ROLE DATA_SERVICE to role SYSADMIN;

GRANT ALL ON WAREHOUSE STITCH_LOADER_SM to ROLE DATA_SERVICE;

GRANT ALL ON DATABASE STITCH_DATA to ROLE DATA_SERVICE;

CREATE USER STITCH_LOADER
   PASSWORD='*****'
   COMMENT='User for Stitch database user'
   DEFAULT_ROLE='DATA_SERVICE'
   DEFAULT_WAREHOUSE='STITCH_LOADER_SM';

GRANT ROLE DATA_SERVICE TO USER STITCH_LOADER;

CREATE NETWORK POLICY STITCH_POLICY
ALLOWED_IP_LIST = ('174.16.250.221','52.23.137.21/32','52.204.223.208/32','52.204.228.32/32','52.204.230.227/32');

ALTER USER STITCH_LOADER SET NETWORK_POLICY = STITCH_POLICY;

/* Create a workbench for analysts to create new views on processed Stitch data.
Move views out of this into production as they are ready for pushes. */
USE DATABASE STITCH_DATA;

CREATE SCHEMA WORKBENCH;

GRANT ALL ON SCHEMA WORKBENCH to ROLE ANALYTICS_ENGINEER;
