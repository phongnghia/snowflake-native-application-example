import streamlit as st
from snowflake.snowpark.context import get_active_session
import snowflake.permissions as permission
import pandas as pd
from sys import exit

session = get_active_session()

# Check if the app has permission to access the referenced student table
student_ref = permission.get_reference_associations("student_table")

if len(student_ref) == 0:
    st.warning("Please bind the student table to continue")
    permission.request_reference("student_table")
    exit(0)

# Get the referenced table name
student_table = student_ref[0]

try:
    # Check permission by running a simple query on the referenced table
    test_query = f"SELECT COUNT(*) FROM {student_table}"
    session.sql(test_query).collect()
except Exception as e:
    st.error(f"Permission error: {str(e)}")
    st.info("The app needs SELECT privilege on the referenced table")
    permission.request_reference("student_table")
    exit(0)

# Main query to fetch student performance data
query = f"""
SELECT 
    s.STUDENT_NAME,
    c.CLASS_NAME,
    s.SCORE,
    app_student_schema.grade_category(s.SCORE) as GRADE
FROM {student_table} s
JOIN app_student_schema.CLASS_TABLE c
ON s.CLASS_ID = c.CLASS_ID
"""

try:
    df = session.sql(query).to_pandas()
    
    st.title("Student Performance Dashboard")
    st.dataframe(df)
    
    # Show the referenced table name in the sidebar
    st.sidebar.success(f"Using table: {student_table}")
    
except Exception as e:
    st.error(f"Query error: {str(e)}")
    st.info("Please check if the referenced table has the required columns: STUDENT_NAME, CLASS_ID, SCORE")