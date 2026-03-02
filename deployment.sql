-- Drop old Database if exists
DROP DATABASE SCHOOL_DB;

-- Set the context for this session
USE ROLE ACCOUNTADMIN;

-- Create Database
CREATE OR REPLACE DATABASE SCHOOL_DB;
USE DATABASE SCHOOL_DB;
-- Create schema
CREATE OR REPLACE SCHEMA SCHOOL_SCHEMA;
USE SCHEMA SCHOOL_SCHEMA;

-- Create table
CREATE OR REPLACE TABLE CLASS_TABLE (
    CLASS_ID INTEGER,
    CLASS_NAME STRING,
    TEACHER_NAME STRING
);
CREATE OR REPLACE TABLE STUDENT_TABLE (
    STUDENT_ID INTEGER,
    STUDENT_NAME STRING,
    CLASS_ID INTEGER,
    SCORE NUMBER(5,2)
);

-- Create data to new database
INSERT INTO CLASS_TABLE VALUES
(1, 'Mathematics', 'Mr. John'),
(2, 'Physics', 'Ms. Anna'),
(3, 'Chemistry', 'Mr. David');
INSERT INTO STUDENT_TABLE VALUES
(101, 'Alice', 1, 85),
(102, 'Bob', 1, 92),
(103, 'Charlie', 2, 78),
(104, 'David', 2, 88),
(105, 'Eva', 3, 91),
(106, 'Frank', 3, 74);

---

-- Drop application if exists
DROP APPLICATION PACKAGE student_mgt_pkg;

-- Create Warehouse for processing
CREATE OR REPLACE WAREHOUSE SCHOOL_WH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create Application package
CREATE APPLICATION PACKAGE student_mgt_pkg;

-- Create schema and stage for application package
CREATE OR REPLACE SCHEMA student_mgt_pkg.student_mgt_pkg_schema;
CREATE OR REPLACE STAGE student_mgt_pkg.student_mgt_pkg_schema.app_stage
    DIRECTORY = ( ENABLE = true );

-- Create shared content schema
CREATE SCHEMA IF NOT EXISTS shared_content_schema;
USE SCHEMA shared_content_schema;

-- Create view
-- CREATE OR REPLACE VIEW CLASS_TABLE AS  SELECT * FROM SCHOOL_DB.SCHOOL_SCHEMA.CLASS_TABLE;
-- CREATE OR REPLACE VIEW STUDENT_TABLE AS  SELECT * FROM SCHOOL_DB.SCHOOL_SCHEMA.STUDENT_TABLE;

-- Important: Grant necessary permissions on shared content to the application package
GRANT USAGE ON SCHEMA shared_content_schema TO SHARE IN APPLICATION PACKAGE student_mgt_pkg;
GRANT REFERENCE_USAGE ON DATABASE SCHOOL_DB TO SHARE IN APPLICATION PACKAGE student_mgt_pkg;
-- GRANT SELECT ON VIEW CLASS_TABLE TO SHARE IN APPLICATION PACKAGE student_mgt_pkg;
-- GRANT SELECT ON VIEW STUDENT_TABLE TO SHARE IN APPLICATION PACKAGE student_mgt_pkg;

-- Register application package version
ALTER APPLICATION PACKAGE student_mgt_pkg
    REGISTER VERSION V1
    USING '@student_mgt_pkg.student_mgt_pkg_schema.app_stage';

-- Create application
CREATE APPLICATION student_mgt_app_v1 
FROM APPLICATION PACKAGE student_mgt_pkg
USING VERSION V1;

-- Show all applications
SHOW APPLICATIONS;