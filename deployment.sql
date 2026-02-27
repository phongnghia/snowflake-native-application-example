-- Drop application if exists
DROP APPLICATION PACKAGE student_app_pkg;

-- Set the context for this session
USE ROLE ACCOUNTADMIN;
USE DATABASE SCHOOL_DB;
USE SCHEMA SCHOOL_SCHEMA;

-- Create Warehouse for processing
CREATE OR REPLACE WAREHOUSE SCHOOL_WH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create Application package
CREATE APPLICATION PACKAGE student_app_pkg;

-- Create schema and stage for application package
CREATE OR REPLACE SCHEMA student_app_pkg.pkg_schema;
CREATE OR REPLACE STAGE student_app_pkg.pkg_schema.app_stage
    DIRECTORY = ( ENABLE = true );

-- Create shared content schema
CREATE SCHEMA IF NOT EXISTS shared_content_sc;
USE SCHEMA shared_content_sc;

-- Create view
CREATE OR REPLACE VIEW CLASS_TABLE AS 
SELECT * FROM SCHOOL_DB.SCHOOL_SCHEMA.CLASS_TABLE;

-- Important: Grant necessary permissions on shared content to the application package
GRANT USAGE ON SCHEMA shared_content_sc TO SHARE IN APPLICATION PACKAGE student_app_pkg;
GRANT REFERENCE_USAGE ON DATABASE SCHOOL_DB TO SHARE IN APPLICATION PACKAGE student_app_pkg;
GRANT SELECT ON VIEW CLASS_TABLE TO SHARE IN APPLICATION PACKAGE student_app_pkg;

-- Grant usage on the application package to the role that will be used to run the application
-- GRANT USAGE ON SCHEMA SCHOOL_SCHEMA TO SHARE IN APPLICATION PACKAGE student_app_pkg;

-- Register application package version
ALTER APPLICATION PACKAGE student_app_pkg
    REGISTER VERSION V1
    USING '@student_app_pkg.pkg_schema.app_stage/src';

-- Create application
CREATE APPLICATION student_app_V1
FROM APPLICATION PACKAGE student_app_pkg
USING VERSION V1;

-- Show all applications
SHOW APPLICATIONS;