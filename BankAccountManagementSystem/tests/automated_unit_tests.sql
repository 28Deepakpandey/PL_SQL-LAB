--------------------------------------------------------------------------------
--  Automated Unit Test Framework for Bank Account Management System
-- Simulates utPLSQL-style testing with PASS/FAIL output
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- ✅ STEP 1: Create ASSERT Procedure (Core of utPLSQL)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE assert_equal (
    p_test_name IN VARCHAR2,
    p_actual    IN NUMBER,
    p_expected  IN NUMBER
) IS
BEGIN
    IF p_actual = p_expected THEN
        DBMS_OUTPUT.PUT_LINE('✔ PASS: ' || p_test_name);
    ELSE
        DBMS_OUTPUT.PUT_LINE('✖ FAIL: ' || p_test_name ||
                             ' | Expected=' || p_expected ||
                             ' Actual=' || p_actual);
    END IF;
END;
/
--------------------------------------------------------------------------------
-- ✅ STEP 2: Create TEST SETUP Procedure (Data Reset + Seed)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE setup_test_data IS
BEGIN
    DELETE FROM transactions;
    DELETE FROM accounts;
    DELETE FROM customers;
    COMMIT;

    create_customer('TestUser1', 'Addr1', '111', 't1@mail.com');
    create_customer('TestUser2', 'Addr2', '222', 't2@mail.com');

    open_account(1001, 'SAVINGS', 5000);
    open_account(1002, 'SAVINGS', 3000);

    DBMS_OUTPUT.PUT_LINE('--- Test Data Setup Complete ---');
END;
/
--------------------------------------------------------------------------------
-- ✅ STEP 3: Individual Test Procedures
--------------------------------------------------------------------------------

-- 🔹 Test: Deposit Money
CREATE OR REPLACE PROCEDURE test_deposit IS
    v_balance NUMBER;
BEGIN
    deposit_money(1001, 2000);
    v_balance := get_balance(1001);

    assert_equal(
        p_test_name => 'Deposit Money',
        p_actual    => v_balance,
        p_expected  => 7000
    );
END;
/
--------------------------------------------------------------------------------
-- 🔹 Test: Withdraw Money
CREATE OR REPLACE PROCEDURE test_withdraw IS
    v_balance NUMBER;
BEGIN
    withdraw_money(1001, 1000);
    v_balance := get_balance(1001);

    assert_equal(
        'Withdraw Money',
        v_balance,
        6000
    );
END;
/
--------------------------------------------------------------------------------
-- 🔹 Test: Transfer Money
CREATE OR REPLACE PROCEDURE test_transfer IS
BEGIN
    transfer_money(1001, 1002, 500);

    assert_equal(
        'Transfer From Account',
        get_balance(1001),
        5500
    );

    assert_equal(
        'Transfer To Account',
        get_balance(1002),
        3500
    );
END;
/
--------------------------------------------------------------------------------
-- 🔹 Test: Negative Balance Trigger
CREATE OR REPLACE PROCEDURE test_negative_balance IS
BEGIN
    UPDATE accounts SET balance = -100 WHERE account_id = 1001;
    DBMS_OUTPUT.PUT_LINE('✖ FAIL: Negative balance allowed');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✔ PASS: Negative balance blocked');
END;
/
--------------------------------------------------------------------------------
-- ✅ STEP 4: Master Test Runner (ut.run equivalent)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE run_all_tests IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('==============================');
    DBMS_OUTPUT.PUT_LINE(' RUNNING BANK SYSTEM TESTS ');
    DBMS_OUTPUT.PUT_LINE('==============================');

    setup_test_data;

    test_deposit;
    test_withdraw;
    test_transfer;
    test_negative_balance;

    DBMS_OUTPUT.PUT_LINE('==============================');
    DBMS_OUTPUT.PUT_LINE(' ALL TESTS COMPLETED ');
    DBMS_OUTPUT.PUT_LINE('==============================');
END;
/
--------------------------------------------------------------------------------
-- ✅ STEP 5: Execute All Tests
--------------------------------------------------------------------------------
BEGIN
    run_all_tests;
END;
/
--------------------------------------------------------------------------------
--  Fully Automated | No Manual Input | PASS / FAIL Report
--------------------------------------------------------------------------------
