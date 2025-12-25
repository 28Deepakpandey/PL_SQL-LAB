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
