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
