-- -- Open New Account
CREATE OR REPLACE PROCEDURE open_account(
    p_customer_id IN NUMBER,
    p_account_type IN VARCHAR2,
    p_balance IN NUMBER DEFAULT 0
) AS
BEGIN
    INSERT INTO accounts (account_id, customer_id, account_type, balance, created_date)
    VALUES (seq_account.NEXTVAL, p_customer_id, p_account_type, p_balance, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Account created successfully.');
END;
/
