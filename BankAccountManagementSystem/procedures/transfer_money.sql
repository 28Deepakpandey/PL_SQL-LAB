-- -- Procedure: transfer_money
CREATE OR REPLACE PROCEDURE transfer_money(
    p_from_account IN NUMBER,
    p_to_account   IN NUMBER,
    p_amount       IN NUMBER
) AS
    v_balance NUMBER;
BEGIN
    -- 1. Check source account balance
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_from_account;
    IF v_balance < p_amount THEN
        -- Insufficient funds
        log_transaction(p_from_account, 'WITHDRAW', p_amount, 'FAILED');
        DBMS_OUTPUT.PUT_LINE('Error: Insufficient balance in source account.');
        RETURN;
    END IF;
    -- 2. Deduct from source account
    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;
    log_transaction(p_from_account, 'WITHDRAW', p_amount, 'SUCCESS');
    -- 3. Add to destination account
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;
    log_transaction(p_to_account, 'DEPOSIT', p_amount, 'SUCCESS');
    -- 4. Confirm success
    DBMS_OUTPUT.PUT_LINE('Transfer of ' || p_amount || 
                         ' from Account ' || p_from_account || 
                         ' to Account ' || p_to_account || ' successful.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('***Transfer failed*** ' || SQLERRM);
END;
/
