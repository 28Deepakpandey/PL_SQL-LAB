-- ********** test using direct VALUES
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
