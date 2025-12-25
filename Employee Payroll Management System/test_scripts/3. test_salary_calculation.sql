-- Salary Calculation with User Input
DECLARE
    v_emp_id NUMBER;
    v_month  VARCHAR2(20);
BEGIN
    v_emp_id := &emp_id;
    v_month  := '&month';  -- e.g. DEC-2025

    payroll_pkg.calculate_salary(v_emp_id, v_month);
END;
/

-- Monthly Report
DECLARE
    v_month VARCHAR2(20);
BEGIN
    v_month := '&month';   -- e.g. DEC-2025, JAN-2026
    payroll_pkg.monthly_report(v_month);
END;
/
