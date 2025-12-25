-- Update Employee
DECLARE
    v_emp_id       NUMBER;
    v_designation  VARCHAR2(50);
    v_basic_salary NUMBER;
BEGIN
    -- Prompt user for values
    v_emp_id       := &emp_id;          -- e.g. 103
    v_designation  := '&designation';   -- e.g. Senior Accountant
    v_basic_salary := &basic_salary;    -- e.g. 50000
    payroll_pkg.update_employee(v_emp_id, v_designation, v_basic_salary);
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_emp_id || ' updated successfully.');
END;
/

-- Delete Employee
DECLARE
    v_emp_id NUMBER;
BEGIN
    v_emp_id := &emp_id;   -- e.g. 101
    payroll_pkg.delete_employee(v_emp_id);
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_emp_id || ' deleted successfully.');
END;
/
