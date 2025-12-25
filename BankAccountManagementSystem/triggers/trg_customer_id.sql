-- Trigger to notify or log customer creation
CREATE OR REPLACE TRIGGER trg_customer_id
AFTER INSERT ON customers
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Dear customer ' || :NEW.name || ' your customer_id is: ' || :NEW.customer_id);
END;
/
