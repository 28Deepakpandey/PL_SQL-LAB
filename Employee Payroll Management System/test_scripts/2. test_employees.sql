-- User‑Input Version for Employees
DECLARE
    v_emp_id       NUMBER;
    v_emp_name     VARCHAR2(50);
    v_designation  VARCHAR2(50);
    v_dept_id      NUMBER;
    v_join_date    DATE;
    v_basic_salary NUMBER;
BEGIN
    -- Prompt user for values
    v_emp_id       := &emp_id;
    v_emp_name     := '&emp_name';
    v_designation  := '&designation';
    v_dept_id      := &dept_id;
    v_join_date    := SYSDATE; -- e.g. 2022-05-10
    v_basic_salary := &basic_salary;

    payroll_pkg.add_employee(v_emp_id, v_emp_name, v_designation, v_dept_id, v_join_date, v_basic_salary);
END;
/
