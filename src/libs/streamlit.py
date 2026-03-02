import streamlit as st
from snowflake.snowpark.context import get_active_session
import snowflake.permissions as permission
from sys import exit

session = get_active_session()

# Check references
student_ref = permission.get_reference_associations("student_table")
class_ref = permission.get_reference_associations("class_table")

if len(student_ref) == 0:
    permission.request_reference("student_table")
    exit(0)

if len(class_ref) == 0:
    permission.request_reference("class_table")
    exit(0)

student_table = "reference('student_table')"
class_table = "reference('class_table')"

with st.spinner("Please wait..."):
    query = f"""
    SELECT 
        s.STUDENT_NAME,
        c.CLASS_NAME,
        s.SCORE,
        app_student_schema.grade_category(s.SCORE) as GRADE
    FROM {student_table} s
    JOIN {class_table} c
    ON s.CLASS_ID = c.CLASS_ID
    """

    df = session.sql(query).to_pandas()

    st.title("Student Performance Dashboard")
    st.dataframe(df)