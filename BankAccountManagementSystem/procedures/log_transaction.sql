-- -- Log Transaction Procedure
CREATE OR REPLACE PROCEDURE log_transaction (
    p_account_id       IN NUMBER,
    p_transaction_type IN VARCHAR2,
    p_amount           IN NUMBER,
    p_status           IN VARCHAR2
) AS
BEGIN
    INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date, status)
    VALUES (
        seq_transaction.NEXTVAL, p_account_id, p_transaction_type, p_amount, SYSDATE, p_status);
END;
/
