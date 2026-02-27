-- Create application role
CREATE APPLICATION ROLE IF NOT EXISTS app_student_role;
-- Create schema
CREATE OR ALTER VERSIONED SCHEMA app_student_schema;
-- Create View
CREATE OR REPLACE VIEW app_student_schema.CLASS_TABLE as select * from shared_content_sc.CLASS_TABLE;
-- Create streamlit
CREATE STREAMLIT IF NOT EXISTS app_student_schema.student_streamlit from '/libs' main_file='streamlit.py';
-- Create function
CREATE OR REPLACE FUNCTION app_student_schema.grade_category(score FLOAT)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
IMPORTS = ('/libs/udf.py')
HANDLER = 'udf.grade_category';
-- Create procedure
CREATE OR REPLACE PROCEDURE app_student_schema.update_reference(ref_name STRING, operation STRING, ref_or_alias STRING)
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
  CASE (operation)
    WHEN 'ADD' THEN
       SELECT system$set_reference(:ref_name, :ref_or_alias);
    WHEN 'REMOVE' THEN
       SELECT system$remove_reference(:ref_name, :ref_or_alias);
    WHEN 'CLEAR' THEN
       SELECT system$remove_all_references();
    ELSE
       RETURN 'Unknown operation: ' || operation;
  END CASE;
  RETURN 'Success';
END;
$$;

-- Grant usage and permissions on objects
GRANT USAGE ON SCHEMA app_student_schema TO APPLICATION ROLE app_student_role;
GRANT SELECT ON VIEW app_student_schema.CLASS_TABLE to application role app_student_role;
GRANT USAGE ON STREAMLIT app_student_schema.student_streamlit TO APPLICATION ROLE app_student_role;
GRANT USAGE ON PROCEDURE app_student_schema.update_reference(string, string, string) TO APPLICATION ROLE app_student_role;