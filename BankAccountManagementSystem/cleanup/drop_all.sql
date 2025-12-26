SET SERVEROUTPUT ON

DECLARE
    PROCEDURE safe_drop(p_sql VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped: ' || p_sql);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Skipped (not exists): ' || p_sql);
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== CLEANUP STARTED =====');

    --------------------------------------------------
    -- Drop triggers
    --------------------------------------------------
    safe_drop('DROP TRIGGER trg_auto_log_transaction');
    safe_drop('DROP TRIGGER trg_no_negative_balance');
    safe_drop('DROP TRIGGER trg_customer_id');

    --------------------------------------------------
    -- Drop MAIN application procedures
    --------------------------------------------------
    safe_drop('DROP PROCEDURE transfer_money');
    safe_drop('DROP PROCEDURE view_transaction_history');
    safe_drop('DROP PROCEDURE withdraw_money');
    safe_drop('DROP PROCEDURE deposit_money');
    safe_drop('DROP PROCEDURE log_transaction');
    safe_drop('DROP PROCEDURE open_account');
    safe_drop('DROP PROCEDURE create_customer');

    --------------------------------------------------
    -- Drop TESTING framework procedures (utPLSQL-style)
    --------------------------------------------------
    safe_drop('DROP PROCEDURE assert_equal');
    safe_drop('DROP PROCEDURE setup_test_data');
    safe_drop('DROP PROCEDURE test_deposit');
    safe_drop('DROP PROCEDURE test_withdraw');
    safe_drop('DROP PROCEDURE test_transfer');
    safe_drop('DROP PROCEDURE test_negative_balance');
    safe_drop('DROP PROCEDURE run_all_tests');

    --------------------------------------------------
    -- Drop functions
    --------------------------------------------------
    safe_drop('DROP FUNCTION get_balance');

    --------------------------------------------------
    -- Drop tables (child → parent)
    --------------------------------------------------
    safe_drop('DROP TABLE transactions CASCADE CONSTRAINTS');
    safe_drop('DROP TABLE accounts CASCADE CONSTRAINTS');
    safe_drop('DROP TABLE customers CASCADE CONSTRAINTS');

    --------------------------------------------------
    -- Drop sequences
    --------------------------------------------------
    safe_drop('DROP SEQUENCE seq_transaction');
    safe_drop('DROP SEQUENCE seq_account');
    safe_drop('DROP SEQUENCE seq_customer');

    DBMS_OUTPUT.PUT_LINE('===== CLEANUP COMPLETED =====');
END;
/
