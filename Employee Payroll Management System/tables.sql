-- --departments
CREATE TABLE departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50),
    location VARCHAR2(50)
);

-- --employees
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(50),
    designation VARCHAR2(50),
    dept_id NUMBER,
    join_date DATE,
    basic_salary NUMBER,
    CONSTRAINT fk_emp_dept
        FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
);

-- --salary_details
CREATE TABLE salary_details (
    salary_id NUMBER PRIMARY KEY,
    emp_id NUMBER,
    salary_month VARCHAR2(10),
    basic NUMBER,
    hra NUMBER,
    bonus NUMBER,
    tax NUMBER,
    net_salary NUMBER,
    CONSTRAINT fk_salary_emp
        FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
);

-- --AUDIT TABLE (for Trigger)
CREATE TABLE salary_audit_log (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
    salary_id NUMBER,
    old_net_salary NUMBER,
    new_net_salary NUMBER,
    changed_on DATE
);

-- --Audit Table for Employees
CREATE TABLE emp_audit (
    emp_id       NUMBER,
    action       VARCHAR2(20),
    action_date  DATE
);
