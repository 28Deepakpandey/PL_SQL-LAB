/***********************************************************************
    🧹 CLEANUP SCRIPT – Student Result System (PL/SQL Project)
    Purpose:
      - Drop all database objects (views, procedures, functions, tables)
      - Reset the environment for fresh re-deployment
************************************************************************/


-------------------------------
-- 1️⃣ DROP VIEW
-------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW view_results';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('View view_results does not exist or already dropped.');
END;
/
 

-------------------------------
-- 2️⃣ DROP PROCEDURES
-------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE insert_student';
    EXECUTE IMMEDIATE 'DROP PROCEDURE insert_subject';
    EXECUTE IMMEDIATE 'DROP PROCEDURE insert_mark';
    EXECUTE IMMEDIATE 'DROP PROCEDURE process_results';
    EXECUTE IMMEDIATE 'DROP PROCEDURE generate_rank';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Some procedures may not exist or were already dropped.');
END;
/
 

-------------------------------
-- 3️⃣ DROP FUNCTION
-------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION calculate_grade';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Function calculate_grade does not exist or already dropped.');
END;
/
 

-------------------------------
-- 4️⃣ DROP TABLES
-------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE results CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE marks CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE subjects CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE students CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Some tables may not exist or were already dropped.');
END;
/
 

-------------------------------
--  CLEANUP COMPLETE
-------------------------------
BEGIN
    DBMS_OUTPUT.PUT_LINE('All database objects cleaned up successfully.');
END;
/
