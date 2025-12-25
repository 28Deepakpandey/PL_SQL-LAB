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
