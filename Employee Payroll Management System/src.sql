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

-- -- salary_details
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

-- --SEQUENCE (for Salary ID)
CREATE SEQUENCE salary_seq
START WITH 1
INCREMENT BY 1;
-- --AUDIT TABLE (for Trigger)
CREATE TABLE salary_audit_log (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
    salary_id NUMBER,
    old_net_salary NUMBER,
    new_net_salary NUMBER,
    changed_on DATE
);


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
-- ---PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY payroll_pkg AS
    -- Tax calculation function
    FUNCTION tax_calculation(p_salary NUMBER)
        RETURN NUMBER IS
    BEGIN
        IF p_salary <= 30000 THEN
            RETURN p_salary * 0.10;
        ELSIF p_salary <= 60000 THEN
            RETURN p_salary * 0.20;
        ELSE
            RETURN p_salary * 0.30;
        END IF;
    END tax_calculation;


    -- Salary calculation procedure
    PROCEDURE calculate_salary(
        p_emp_id NUMBER,
        p_month VARCHAR2
    ) IS
        v_basic employees.basic_salary%TYPE;
        v_hra   NUMBER;
        v_bonus NUMBER;
        v_tax   NUMBER;
        v_net   NUMBER;
    BEGIN
        SELECT basic_salary
        INTO v_basic
        FROM employees
        WHERE emp_id = p_emp_id;

        v_hra   := v_basic * 0.20;
        v_bonus := v_basic * 0.10;
        v_tax   := tax_calculation(v_basic + v_hra + v_bonus);
        v_net   := v_basic + v_hra + v_bonus - v_tax;

        INSERT INTO salary_details
        VALUES (
            salary_seq.NEXTVAL,
            p_emp_id,
            p_month,
            v_basic,
            v_hra,
            v_bonus,
            v_tax,
            v_net
        );

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Employee not found.');
    END calculate_salary;


    -- Monthly report using cursor
    PROCEDURE monthly_report(p_month VARCHAR2) IS
        CURSOR c_salary IS
            SELECT e.emp_name, d.dept_name, s.net_salary
            FROM employees e
            JOIN departments d ON e.dept_id = d.dept_id
            JOIN salary_details s ON e.emp_id = s.emp_id
            WHERE s.salary_month = p_month;
    BEGIN
        FOR rec IN c_salary LOOP
            DBMS_OUTPUT.PUT_LINE(
                rec.emp_name || ' | ' ||
                rec.dept_name || ' | ' ||
                rec.net_salary
            );
        END LOOP;
    END monthly_report;


    -- Add department
    PROCEDURE add_department (
        p_dept_id   NUMBER,
        p_dept_name VARCHAR2,
        p_location  VARCHAR2
    ) IS
    BEGIN
        INSERT INTO departments
        VALUES (p_dept_id, p_dept_name, p_location);
        COMMIT;
    END add_department;


    -- Add employee
    PROCEDURE add_employee (
        p_emp_id       NUMBER,
        p_emp_name     VARCHAR2,
        p_designation  VARCHAR2,
        p_dept_id      NUMBER,
        p_join_date    DATE,
        p_basic_salary NUMBER
    ) IS
    BEGIN
        INSERT INTO employees
        VALUES (
            p_emp_id,
            p_emp_name,
            p_designation,
            p_dept_id,
            p_join_date,
            p_basic_salary
        );
        COMMIT;
    END add_employee;


    -- Update employee
    PROCEDURE update_employee (
        p_emp_id NUMBER,
        p_designation VARCHAR2,
        p_basic_salary NUMBER
    ) IS
    BEGIN
        UPDATE employees
        SET designation = p_designation,
            basic_salary = p_basic_salary
        WHERE emp_id = p_emp_id;
        COMMIT;
    END update_employee;


    -- Delete employee
    PROCEDURE delete_employee (
            p_emp_id NUMBER
        ) IS
        BEGIN
            DELETE FROM salary_details
            WHERE emp_id = p_emp_id;

            DELETE FROM employees
            WHERE emp_id = p_emp_id;

            COMMIT;
        END delete_employee;
END payroll_pkg;
/


-- --TRIGGER (Audit Salary Changes)
CREATE OR REPLACE TRIGGER audit_salary_changes
AFTER UPDATE OF net_salary ON salary_details
FOR EACH ROW
BEGIN
    INSERT INTO salary_audit_log (
        salary_id,
        old_net_salary,
        new_net_salary,
        changed_on
    )
    VALUES (
        :OLD.salary_id,
        :OLD.net_salary,
        :NEW.net_salary,
        SYSDATE
    );
END;
/


-- --Audit Trigger on Employees
-- Create an audit table
CREATE TABLE emp_audit (
    emp_id       NUMBER,
    action       VARCHAR2(20),
    action_date  DATE
);

-- Create a trigger on employees
CREATE OR REPLACE TRIGGER trg_emp_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO emp_audit VALUES (:NEW.emp_id, 'INSERT', SYSDATE);
    ELSIF UPDATING THEN
        INSERT INTO emp_audit VALUES (:NEW.emp_id, 'UPDATE', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO emp_audit VALUES (:OLD.emp_id, 'DELETE', SYSDATE);
    END IF;
END;
/



-- *********************************complete*************************--
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


--Salary Calculation with User Input
DECLARE
    v_emp_id NUMBER;
    v_month  VARCHAR2(20);
BEGIN
    v_emp_id := &emp_id;
    v_month  := '&month';  -- e.g. DEC-2025

    payroll_pkg.calculate_salary(v_emp_id, v_month);
END;
/

-- --monthly_report
DECLARE
    v_month VARCHAR2(20);
BEGIN
    v_month := '&month';   -- e.g. DEC-2025, JAN-2026
    payroll_pkg.monthly_report(v_month);
END;
/



-- --Update Employee
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

-- --Delete Employee
DECLARE
    v_emp_id NUMBER;
BEGIN
    v_emp_id := &emp_id;   -- e.g. 101
    payroll_pkg.delete_employee(v_emp_id);
    DBMS_OUTPUT.PUT_LINE('Employee ' || v_emp_id || ' deleted successfully.');
END;
/


-- --Test audit_salary_changes with User Input
    -- --This trigger fires AFTER UPDATE OF net_salary on salary_details.
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




-- --Test trg_emp_audit with User Input
    -- --This trigger fires AFTER INSERT/UPDATE/DELETE on employees.
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



