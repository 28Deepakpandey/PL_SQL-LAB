-- -- Withdraw Money Procedure
CREATE OR REPLACE PROCEDURE withdraw_money(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;

    IF v_balance < p_amount THEN
        log_transaction(p_account_id, 'WITHDRAW', p_amount, 'FAILED');
        DBMS_OUTPUT.PUT_LINE('Insufficient balance.');
    ELSE
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = p_account_id;

        -- log_transaction(p_account_id, 'WITHDRAW', p_amount, 'SUCCESS');
        DBMS_OUTPUT.PUT_LINE('Withdrawal successful.');
    END IF;
END;
/
