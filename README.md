# Student Class Management Native Application

## Overview

The **Student Class Management App** is a Snowflake Native Application that enables consumers to:

* Analyze student performance
* Join student and class data securely
* Categorize grades using a Python UDF
* Visualize results via Streamlit in Snowflake

This application demonstrates:

* Snowflake Native Application Framework
* Secure data sharing via references
* Python UDF inside Snowflake
* Streamlit-based UI
* Versioned application packaging

---

## Architecture

```
Application Package
│
├── manifest.yml
├── environment.yml
├── scripts/setup.sql
├── libs/streamlit.py
└── libs/udf.py
```

When installed, Snowflake:

1. Creates an application instance
2. Executes `setup.sql`
3. Registers UDFs
4. Deploys Streamlit UI
5. Requests data references from the consumer

Each application instance runs in an isolated secure container.

---

## Data Model (Consumer Side)

The application expects the consumer to provide two tables:

### CLASS

| Column       | Type    |
| ------------ | ------- |
| CLASS_ID     | INTEGER |
| CLASS_NAME   | STRING  |
| TEACHER_NAME | STRING  |

### STUDENT

| Column       | Type        |
| ------------ | ----------- |
| STUDENT_ID   | INTEGER     |
| STUDENT_NAME | STRING      |
| CLASS_ID     | INTEGER     |
| SCORE        | NUMBER(5,2) |

---

## Sample Data Setup

```sql
CREATE OR REPLACE DATABASE SCHOOL_DB;
USE DATABASE SCHOOL_DB;
CREATE OR REPLACE SCHEMA PUBLIC;

CREATE OR REPLACE TABLE CLASS (
    CLASS_ID INTEGER,
    CLASS_NAME STRING,
    TEACHER_NAME STRING
);

CREATE OR REPLACE TABLE STUDENT (
    STUDENT_ID INTEGER,
    STUDENT_NAME STRING,
    CLASS_ID INTEGER,
    SCORE NUMBER(5,2)
);

INSERT INTO CLASS VALUES
(1, 'Mathematics', 'Mr. John'),
(2, 'Physics', 'Ms. Anna'),
(3, 'Chemistry', 'Mr. David');

INSERT INTO STUDENT VALUES
(101, 'Alice', 1, 85),
(102, 'Bob', 1, 92),
(103, 'Charlie', 2, 78),
(104, 'David', 2, 88),
(105, 'Eva', 3, 91),
(106, 'Frank', 3, 74);
```

---

## Features

### 1️⃣ Secure Data Access

The application uses reference objects to request access to:

* `student_table`
* `class_table`

The consumer must approve these references before the app can query the data.

---

### 2️⃣ Python UDF – Grade Categorization

A Python UDF categorizes student scores:

| Score Range | Category  |
| ----------- | --------- |
| ≥ 90        | Excellent |
| 80–89       | Good      |
| 70–79       | Average   |
| < 70        | Poor      |

The UDF runs inside Snowflake’s secure runtime environment.

---

### 3️⃣ Streamlit Dashboard

The app renders:

* Student name
* Class name
* Score
* Grade category

All computation happens inside Snowflake.

---

## Installation (Developer Flow)

### 1️⃣ Create Application Package

```sql
CREATE APPLICATION PACKAGE student_app_pkg;
```

### 2️⃣ Create Stage

```sql
CREATE SCHEMA student_app_pkg.pkg_schema;
CREATE STAGE student_app_pkg.pkg_schema.app_stage;
```

### 3️⃣ Upload Artifacts

```sql
PUT file://manifest.yml @student_app_pkg.pkg_schema.app_stage;
PUT file://scripts/setup.sql @student_app_pkg.pkg_schema.app_stage/scripts;
PUT file://app/streamlit.py @student_app_pkg.pkg_schema.app_stage/app;
PUT file://app/udf.py @student_app_pkg.pkg_schema.app_stage/app;
PUT file://environment.yml @student_app_pkg.pkg_schema.app_stage;
```

### 4️⃣ Add Version

```sql
ALTER APPLICATION PACKAGE student_app_pkg
ADD VERSION V1
USING '@student_app_pkg.pkg_schema.app_stage';
```

### 5️⃣ Install Application

```sql
CREATE APPLICATION student_app
FROM APPLICATION PACKAGE student_app_pkg
VERSION V1;
```

---

## Upgrading the Application

Versions are immutable in Snowflake.

To release a new version:

```sql
ALTER APPLICATION PACKAGE student_app_pkg
ADD VERSION V2
USING '@student_app_pkg.pkg_schema.app_stage';
```

Upgrade an existing app:

```sql
ALTER APPLICATION student_app
UPGRADE TO VERSION V2;
```

---

## Security Model

* No direct access to consumer tables
* All data access through approved references
* Each application instance runs in isolation
* No internet access inside runtime
* All dependencies declared in `environment.yml`

---

## Development Notes

* Versions cannot be overwritten.
* Use incremental version naming (V1, V2, V3).
* Avoid creating account-level objects in `setup.sql`.
* Always use `CREATE OR REPLACE` for internal objects.

---

## Use Cases

This example app can be extended for:

* Academic performance dashboards
* Department-level analytics
* Student performance prediction (ML integration)
* Multi-school tenant architecture

---

## Snowflake CLI

Create environment

``` code

python -m venv venv

.\venv\Scripts\activate

python.exe -m pip install -r .\requirements.txt

```

Create connection to snowflake server

``` code

snow connection add

```

## License

Internal development example for educational purposes.
