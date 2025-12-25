-- --View Transaction History
CREATE OR REPLACE PROCEDURE view_transaction_history(p_account_id IN NUMBER) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Transaction_ID | Type | Amount | Date | Status');
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
  FOR rec IN (
      SELECT transaction_id, transaction_type, amount, transaction_date, status
      FROM transactions
      WHERE account_id = p_account_id
      ORDER BY transaction_date DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(rec.transaction_id || ' | ' || rec.transaction_type || ' | ' ||
                         rec.amount || ' | ' || TO_CHAR(rec.transaction_date, 'DD-MON-YYYY HH:MI') || ' | ' || rec.status);
  END LOOP;
END;
/
