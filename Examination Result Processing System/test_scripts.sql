/***********************************************************************
   TEST SCRIPTS – Student Result System (PL/SQL Project)
    This file includes all test, demo, and validation scripts for:
    - Table verification
    - Sample data insertion
    - Procedure and function testing
    - Result processing and ranking
    - View validation
    - Exception handling
************************************************************************/


-------------------------------
-- 1️⃣ VIEW INITIAL TABLES
-------------------------------
SELECT * FROM students;
SELECT * FROM subjects;
SELECT * FROM marks;
SELECT * FROM results;


-------------------------------
-- 2️⃣ INSERT SAMPLE DATA (MANUAL)
-------------------------------
/*
-- Students
INSERT INTO students VALUES (101, 'Rahul Sharma', 'Computer Science', 2, 'rahul@gmail.com');
INSERT INTO students VALUES (102, 'Anita Verma', 'Information Technology', 2, 'anita@gmail.com');
INSERT INTO students VALUES (103, 'Karan Singh', 'Computer Science', 3, 'karan@gmail.com');

-- Subjects
INSERT INTO subjects VALUES (1, 'Database Systems', 100);
INSERT INTO subjects VALUES (2, 'Operating Systems', 100);
INSERT INTO subjects VALUES (3, 'Computer Networks', 100);

-- Marks
INSERT INTO marks VALUES (1, 101, 1, 85);
INSERT INTO marks VALUES (2, 101, 2, 78);
INSERT INTO marks VALUES (3, 101, 3, 90);

INSERT INTO marks VALUES (4, 102, 1, 65);
INSERT INTO marks VALUES (5, 102, 2, 72);
INSERT INTO marks VALUES (6, 102, 3, 68);

INSERT INTO marks VALUES (7, 103, 1, 92);
INSERT INTO marks VALUES (8, 103, 2, 88);
INSERT INTO marks VALUES (9, 103, 3, 95);
*/


-------------------------------
-- 3️⃣ INSERT USING PROCEDURES (USER INPUT)
-------------------------------

-- Insert a Student
DECLARE
    v_id       NUMBER;
    v_name     VARCHAR2(50);
    v_dept     VARCHAR2(30);
    v_year     NUMBER;
    v_email    VARCHAR2(50);
BEGIN
    v_id := &student_id;
    v_name := '&student_name';
    v_dept := '&department';
    v_year := &year;
    v_email := '&email';
    insert_student(v_id, v_name, v_dept, v_year, v_email);
END;
/

-- Insert a Subject
DECLARE
    v_id    NUMBER;
    v_name  VARCHAR2(50);
    v_max   NUMBER;
BEGIN
    v_id := &subject_id;
    v_name := '&subject_name';
    v_max := &max_marks;
    insert_subject(v_id, v_name, v_max);
END;
/

-- Insert Marks
DECLARE
    v_mark_id        NUMBER;
    v_student_id     NUMBER;
    v_subject_id     NUMBER;
    v_marks_obtained NUMBER;
BEGIN
    v_mark_id := &mark_id;
    v_student_id := &student_id;
    v_subject_id := &subject_id;
    v_marks_obtained := &marks_obtained;
    insert_mark(v_mark_id, v_student_id, v_subject_id, v_marks_obtained);
END;
/

-------------------------------
-- 4️⃣ TEST GRADE FUNCTION
-------------------------------
SELECT calculate_grade(95) AS grade FROM dual; -- Expected: A
SELECT calculate_grade(82) AS grade FROM dual; -- Expected: B
SELECT calculate_grade(65) AS grade FROM dual; -- Expected: C


-------------------------------
-- 5️⃣ PROCESS RESULTS
-------------------------------
-- Ensure results are calculated and inserted properly
BEGIN
    process_results;
END;
/
SELECT * FROM results;


-------------------------------
-- 6️⃣ GENERATE RANKS
-------------------------------
BEGIN
    generate_rank;
END;
/
SELECT * FROM results ORDER BY rank;


-------------------------------
-- 7️⃣ TEST VIEW OUTPUT
-------------------------------
SELECT * FROM view_results;


-------------------------------
-- 8️⃣ TEST DIRECT INSERTS VIA PROCEDURES
-------------------------------

-- Insert a new student
DECLARE
BEGIN
    insert_student(104, 'Neha Kapoor', 'Computer Science', 2, 'neha@gmail.com');
END;
/

-- Insert a new subject
DECLARE
BEGIN
    insert_subject(4, 'Data Structures', 100);
END;
/

-- Insert marks for the new student
DECLARE
BEGIN
    insert_mark(10, 104, 1, 88);
    insert_mark(11, 104, 2, 79);
    insert_mark(12, 104, 3, 92);
END;
/

-- Re-run results and ranking for new data
BEGIN
    process_results;
    generate_rank;
END;
/
SELECT * FROM view_results;


-------------------------------
-- 9️⃣ TEST EXCEPTION HANDLING
-------------------------------
-- Attempt to insert marks for a non-existing student
BEGIN
    insert_mark(13, 999, 1, 80); -- student_id 999 does not exist
END;
/
