-- Test audit_salary_changes Trigger
DECLARE
    v_salary_id    NUMBER;
    v_new_salary   NUMBER;
BEGIN
    -- Prompt user for values
    v_salary_id  := &salary_id;     -- e.g. 201
    v_new_salary := &new_salary;    -- e.g. 37000
    UPDATE salary_details
    SET net_salary = v_new_salary
    WHERE salary_id = v_salary_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salary updated for ID ' || v_salary_id);
END;
/
-- Verify audit log
SELECT * FROM salary_audit_log WHERE salary_id = &salary_id;

-- Test trg_emp_audit Trigger
DECLARE
    v_emp_id       NUMBER;
    v_emp_name     VARCHAR2(50);
    v_designation  VARCHAR2(50);
    v_dept_id      NUMBER;
    v_basic_salary NUMBER;
BEGIN
    -- Prompt user for values
    v_emp_id       := &emp_id;          -- e.g. 120
    v_emp_name     := '&emp_name';      -- e.g. Test User
    v_designation  := '&designation';   -- e.g. Intern
    v_dept_id      := &dept_id;         -- e.g. 1
    v_basic_salary := &basic_salary;    -- e.g. 20000
    -- Insert employee (fires INSERT trigger)
    INSERT INTO employees (emp_id, emp_name, designation, dept_id, join_date, basic_salary)
    VALUES (v_emp_id, v_emp_name, v_designation, v_dept_id, SYSDATE, v_basic_salary);
    -- Update employee (fires UPDATE trigger)
    UPDATE employees SET basic_salary = basic_salary + 5000 WHERE emp_id = v_emp_id;
    -- Delete employee (fires DELETE trigger)
    DELETE FROM employees WHERE emp_id = v_emp_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_emp_id || ' tested for INSERT, UPDATE, DELETE.');
END;
/
-- Verify audit log
SELECT * FROM emp_audit WHERE emp_id = &emp_id;
