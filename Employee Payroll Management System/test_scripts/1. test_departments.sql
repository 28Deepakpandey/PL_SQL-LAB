-- User‑Input Version for Departments
DECLARE
    v_dept_id   NUMBER;
    v_dept_name VARCHAR2(50);
    v_location  VARCHAR2(50);
BEGIN
    -- Prompt user for values
    v_dept_id   := &dept_id;
    v_dept_name := '&dept_name';
    v_location  := '&location';

    payroll_pkg.add_department(v_dept_id, v_dept_name, v_location);
END;
/
