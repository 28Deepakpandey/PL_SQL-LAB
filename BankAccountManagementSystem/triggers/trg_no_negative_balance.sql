-- -- “Prevent Negative Balance” Trigger
CREATE OR REPLACE TRIGGER trg_no_negative_balance
BEFORE UPDATE OF balance ON accounts
FOR EACH ROW
BEGIN
  IF :NEW.balance < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Balance cannot be negative.');
  END IF;
END;
/
