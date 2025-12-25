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


-- -- 2. Open account:
BEGIN
  open_account(&p_customer_id, '&p_account_type', &p_balance);
END;
/

-- --3. Deposit:
BEGIN
  deposit_money(&p_account_id, &p_amount);
END;
/

-- -- 4. Withdraw:
BEGIN
  withdraw_money(&p_account_id, &p_amount);
END;
/

-- --5. Check balance:
BEGIN
  DBMS_OUTPUT.PUT_LINE('Balance: ' || get_balance(&p_account_id));
END;
/

-- --6. View transaction history:
BEGIN
  view_transaction_history(&p_account_id);
END;
/

