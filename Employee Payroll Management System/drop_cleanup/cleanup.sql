-- Drop tables in dependency order

DROP TABLE salary_audit_log CASCADE CONSTRAINTS;
DROP TABLE salary_details CASCADE CONSTRAINTS;
DROP TABLE emp_audit CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;


-- Drop sequences
DROP SEQUENCE salary_seq;


-- Drop package and package body
DROP PACKAGE payroll_pkg;



-- Drop sequences
DROP SEQUENCE salary_seq;


-- Drop triggers
DROP TRIGGER audit_salary_changes;
DROP TRIGGER trg_emp_audit;
