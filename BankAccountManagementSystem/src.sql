/*===== BANK ACCOUNT MANAGEMENT SYSTEM =====
1. Create New Customer
2. Open New Account
3. Deposit Money
4. Withdraw Money
5. Check Balance
6. View Transaction History
7. Money Tranfer
=========================================
Enter your choice:
*/



-- -- Create the sequence
CREATE SEQUENCE seq_customer START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_account START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_transaction START WITH 1001 INCREMENT BY 1;

-- -- 1️ CUSTOMERS Table
CREATE TABLE customers (
    customer_id  NUMBER PRIMARY KEY,
    name         VARCHAR2(100) NOT NULL,
    address      VARCHAR2(255),
    phone        VARCHAR2(20),
    email        VARCHAR2(100)
);

-- -- 2 ACCOUNTS Table
CREATE TABLE accounts (
    account_id   NUMBER PRIMARY KEY,
    customer_id  NUMBER NOT NULL,
    account_type VARCHAR2(20) 
        CHECK (account_type IN ('SAVINGS', 'CURRENT')),
    balance      NUMBER(12,2) DEFAULT 0 CHECK (balance >= 0),
    created_date DATE DEFAULT SYSDATE,

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- -- 3 TRANSACTIONS Table
CREATE TABLE transactions (
    transaction_id   NUMBER PRIMARY KEY,
    account_id       NUMBER NOT NULL,
    transaction_type VARCHAR2(20)
        CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAW')),
    amount           NUMBER(12,2) CHECK (amount > 0),
    transaction_date DATE DEFAULT SYSDATE,
    status           VARCHAR2(20)
        CHECK (status IN ('SUCCESS', 'FAILED')),

    CONSTRAINT fk_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);


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



-- -- Deposit Money Procedure
CREATE OR REPLACE PROCEDURE deposit_money(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    log_transaction(p_account_id, 'DEPOSIT', p_amount, 'SUCCESS');
    DBMS_OUTPUT.PUT_LINE('Deposit successful.');
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback ensures atomicity
        ROLLBACK;
        INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date, status)
        VALUES (seq_transaction.NEXTVAL, p_account_id, 'DEPOSIT', p_amount, SYSDATE, 'FAILED');
        DBMS_OUTPUT.PUT_LINE('***Deposit failed***');
END;
/


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

        log_transaction(p_account_id, 'WITHDRAW', p_amount, 'SUCCESS');
        DBMS_OUTPUT.PUT_LINE('Withdrawal successful.');
    END IF;
END;
/



-- -- Check Balance Function
CREATE OR REPLACE FUNCTION get_balance(p_account_id IN NUMBER)
RETURN NUMBER IS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;
    RETURN v_balance;
END;
/

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







---------------------*********************************************************************************************************------------------------------------
--------test:
-- --1. Create customer:
DECLARE
  v_count NUMBER := &num_customers; -- how many customers to create
  v_name    VARCHAR2(100);
  v_address VARCHAR2(255);
  v_phone   VARCHAR2(20);
  v_email   VARCHAR2(100);
BEGIN
  FOR i IN 1..v_count LOOP
    v_name    := '&p_name';
    v_address := '&p_address';
    v_phone   := '&p_phone';
    v_email   := '&p_email';

    create_customer(v_name, v_address, v_phone, v_email);
    DBMS_OUTPUT.PUT_LINE('Customer ' || i || ' created successfully.');
  END LOOP;
END;
/

-- -- 2.Open account:
BEGIN
  open_account(&p_customer_id, '&p_account_type', &p_balance);
END;
/
-- --3. Deposit:
BEGIN
  deposit_money(&p_account_id, &p_amount);
END;
/

-- -- 4.Withdraw:
BEGIN
  withdraw_money(&p_account_id, &p_amount);
END;
/
-- --5. Check balance:
BEGIN
  DBMS_OUTPUT.PUT_LINE('Balance: ' || get_balance(&p_account_id));
END;
/

-- --6.View transaction history:
BEGIN
  view_transaction_history(&p_account_id);
END;
/