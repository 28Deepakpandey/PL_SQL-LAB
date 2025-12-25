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
    account_type VARCHAR2(20),
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
    transaction_type VARCHAR2(20),
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



-- ********** test useing direct VALUES
-- 🧪 TEST CASE 1: Create Customers
-- Expected: Customers inserted, IDs auto-generated
BEGIN
  create_customer('Alice', 'New York', '1111111111', 'alice@mail.com');
  create_customer('Bob', 'London', '2222222222', 'bob@mail.com');
END;
/
SELECT * FROM customers;


-- 🧪 TEST CASE 2: Open Accounts
-- Expected: Accounts linked to customers
BEGIN
  open_account(1001, 'SAVINGS', 5000);
  open_account(1002, 'CURRENT', 3000);
END;
/
SELECT * FROM accounts;

-- 🧪 TEST CASE 3: Deposit Money
-- Expected: Balance increases + transaction logged by trigger
BEGIN
  deposit_money(1001, 2000);
END;
/
SELECT balance FROM accounts WHERE account_id = 1001;
SELECT * FROM transactions WHERE account_id = 1001;

-- 🧪 TEST CASE 4: Withdraw Money (SUCCESS)
-- Expected: Balance decreases + transaction logged
BEGIN
  withdraw_money(1001, 1000);
END;
/
SELECT balance FROM accounts WHERE account_id = 1001;
SELECT * FROM transactions WHERE account_id = 1001;

-- 🧪 TEST CASE 5: Withdraw Money (INSUFFICIENT FUNDS)
-- Expected: No balance change, FAILED transaction logged
BEGIN
  withdraw_money(1002, 10000);
END;
/
SELECT balance FROM accounts WHERE account_id = 1002;
SELECT * FROM transactions WHERE account_id = 1002;

-- 🧪 TEST CASE 6: Check Balance Function
-- Expected: Correct balance returned
BEGIN
  DBMS_OUTPUT.PUT_LINE('Balance: ' || get_balance(1001));
END;
/

-- 🧪 TEST CASE 7: Trigger Test (Direct UPDATE)
-- Expected: Transaction auto-logged by trigger
UPDATE accounts
SET balance = balance + 500
WHERE account_id = 1001;
SELECT * FROM transactions WHERE account_id = 1001 ORDER BY transaction_id DESC;

-- 🧪 TEST CASE 8: Negative Balance Prevention Trigger
-- Expected: ERROR raised, update blocked
UPDATE accounts
SET balance = -100
WHERE account_id = 1001;

-- 🧪 TEST CASE 9: Money Transfer (SUCCESS)
-- Expected:
    -- Deduct from source
    -- Add to destination
    -- Transactions logged
BEGIN
  transfer_money(1001, 1002, 500);
END;
/
SELECT account_id, balance FROM accounts;
SELECT * FROM transactions ORDER BY transaction_id;

-- 🧪 TEST CASE 10: Money Transfer (FAILURE)
-- Expected: No balances changed
BEGIN
  transfer_money(1002, 1001, 99999);
END;
/
SELECT account_id, balance FROM accounts;


-- 🧪 TEST CASE 11: View Transaction History
-- Expected: Formatted transaction list
BEGIN
  view_transaction_history(1001);
END;
/

-- 🧪 TEST CASE 12: Invalid Account ID
-- Expected: NO_DATA_FOUND error
BEGIN
  deposit_money(9999, 100);
END;
/


-- FINAL VALIDATION QUERIES
SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM transactions ORDER BY transaction_id;















-- Drop object created in this project******************


BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER trg_auto_log_transaction';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/


BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER trg_no_negative_balance';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE transfer_money';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE view_transaction_history';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE withdraw_money';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE deposit_money';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE log_transaction';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE open_account';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE create_customer';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP FUNCTION get_balance';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE transactions CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE accounts CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_transaction';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_account';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_customer';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
