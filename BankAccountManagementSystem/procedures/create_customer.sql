-- -- Create New Customer
CREATE OR REPLACE PROCEDURE create_customer(
    p_name    IN VARCHAR2,
    p_address IN VARCHAR2,
    p_phone   IN VARCHAR2,
    p_email   IN VARCHAR2
) AS
BEGIN
    INSERT INTO customers (customer_id, name, address, phone, email)
    VALUES (seq_customer.NEXTVAL, p_name, p_address, p_phone, p_email);

    DBMS_OUTPUT.PUT_LINE('Customer created successfully.');
END;
/
