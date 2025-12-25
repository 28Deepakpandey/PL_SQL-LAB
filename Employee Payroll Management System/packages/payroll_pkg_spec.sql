-- --PACKAGE SPECIFICATION
CREATE OR REPLACE PACKAGE payroll_pkg AS

    FUNCTION tax_calculation(p_salary NUMBER)
        RETURN NUMBER;

    PROCEDURE calculate_salary(
        p_emp_id NUMBER,
        p_month VARCHAR2
    );

    PROCEDURE monthly_report(
        p_month VARCHAR2
    );

    PROCEDURE add_department (
        p_dept_id   NUMBER,
        p_dept_name VARCHAR2,
        p_location  VARCHAR2
    );

    PROCEDURE add_employee (
        p_emp_id       NUMBER,
        p_emp_name     VARCHAR2,
        p_designation  VARCHAR2,
        p_dept_id      NUMBER,
        p_join_date    DATE,
        p_basic_salary NUMBER
    );

    PROCEDURE update_employee (
        p_emp_id NUMBER,
        p_designation VARCHAR2,
        p_basic_salary NUMBER
    );

    PROCEDURE delete_employee (
        p_emp_id NUMBER
    );

END payroll_pkg;
/
