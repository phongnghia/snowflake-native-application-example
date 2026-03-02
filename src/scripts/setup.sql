-- Create application role
CREATE APPLICATION ROLE IF NOT EXISTS app_student_role;

-- Create schema and grant permission to application role
CREATE OR ALTER VERSIONED SCHEMA app_student_schema;
GRANT USAGE ON SCHEMA app_student_schema TO APPLICATION ROLE app_student_role;

-- Create View and grant permision to application role
-- CREATE OR REPLACE VIEW app_student_schema.STUDENT_TABLE AS SELECT * FROM shared_content_schema.STUDENT_TABLE;
-- CREATE OR REPLACE VIEW app_student_schema.CLASS_TABLE AS SELECT * FROM shared_content_schema.CLASS_TABLE;
-- GRANT SELECT ON VIEW app_student_schema.STUDENT_TABLE TO APPLICATION ROLE app_student_role;
-- GRANT SELECT ON VIEW app_student_schema.CLASS_TABLE TO APPLICATION ROLE app_student_role;

-- Create procedure and grant permission to application role
CREATE OR REPLACE PROCEDURE app_student_schema.update_reference(ref_name STRING, ref_operation STRING, ref_or_alias STRING)
RETURNS STRING
LANGUAGE SQL
AS $$
BEGIN
    CASE (ref_operation)
        WHEN 'ADD' THEN
            SELECT system$set_reference(:ref_name, :ref_or_alias);
        WHEN 'REMOVE' THEN
            SELECT system$remove_reference(:ref_name, :ref_or_alias);
        WHEN 'CLEAR' THEN
            SELECT system$remove_all_references();
        ELSE
            RETURN 'Unkown operation: ' || ref_operation;
    END CASE;
    RETURN 'Success';
END;
$$;
GRANT USAGE ON PROCEDURE app_student_schema.update_reference(string, string, string) TO APPLICATION ROLE app_student_role;

-- Create function and grant permission to application role
CREATE OR REPLACE FUNCTION app_student_schema.grade_category(score FLOAT)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
IMPORTS = ('/src/libs/udf.py')
HANDLER = 'udf.grade_category';
GRANT USAGE ON FUNCTION app_student_schema.grade_category(float) TO APPLICATION ROLE app_student_role;

-- Create streamlit and grant permission to application role
CREATE STREAMLIT IF NOT EXISTS app_student_schema.student_mgt_streamlit from '/src/libs' main_file='streamlit.py';
GRANT USAGE ON STREAMLIT app_student_schema.student_mgt_streamlit TO APPLICATION ROLE app_student_role;