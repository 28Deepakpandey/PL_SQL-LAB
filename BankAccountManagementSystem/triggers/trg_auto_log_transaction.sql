-- -- Auto Log Transaction After Balance Change
-- -- Why: So even if someone updates balance directly (without calling our procedure), a transaction record still gets created.
CREATE OR REPLACE TRIGGER trg_auto_log_transaction
AFTER UPDATE OF balance ON accounts
FOR EACH ROW
BEGIN
  IF :NEW.balance > :OLD.balance THEN
    INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date, status)
    VALUES (seq_transaction.NEXTVAL, :NEW.account_id, 'DEPOSIT', :NEW.balance - :OLD.balance, SYSDATE, 'SUCCESS');

  ELSIF :NEW.balance < :OLD.balance THEN
    INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date, status)
    VALUES (seq_transaction.NEXTVAL, :NEW.account_id, 'WITHDRAW', :OLD.balance - :NEW.balance, SYSDATE, 'SUCCESS');
  END IF;
END;
/
