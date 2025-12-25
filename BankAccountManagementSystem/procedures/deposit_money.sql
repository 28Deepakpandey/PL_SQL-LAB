-- -- Deposit Money Procedure
CREATE OR REPLACE PROCEDURE deposit_money(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    -- 1️ Validate amount
    IF p_amount <= 0 THEN
        INSERT INTO transactions (
            transaction_id, account_id, transaction_type, amount, transaction_date, status
        )
        VALUES (
            seq_transaction.NEXTVAL, p_account_id, 'DEPOSIT', p_amount, SYSDATE, 'FAILED'
        );
        DBMS_OUTPUT.PUT_LINE('Deposit amount must be greater than zero.');
        DBMS_OUTPUT.PUT_LINE('***Deposit failed***');
        RETURN; -- exit the procedure
    END IF;

    -- 2️ Update account
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    -- 3️ Check if account exists
    IF SQL%ROWCOUNT = 0 THEN
        
        DBMS_OUTPUT.PUT_LINE('Account does not exist.');
        DBMS_OUTPUT.PUT_LINE('***Deposit failed***');
        RETURN; -- exit procedure
    END IF;

    -- 4 Success
    DBMS_OUTPUT.PUT_LINE('Deposit successful.');
END;
/
