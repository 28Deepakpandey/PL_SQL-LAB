--Create STUDENTS Table
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    student_name VARCHAR2(50) NOT NULL,
    department VARCHAR2(30),
    year NUMBER,
    email VARCHAR2(50)
);

-- Create SUBJECTS Table
CREATE TABLE subjects (
    subject_id NUMBER PRIMARY KEY,
    subject_name VARCHAR2(50) NOT NULL,
    max_marks NUMBER NOT NULL
);
-- Create MARKS Table
CREATE TABLE marks (
    mark_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    subject_id NUMBER,
    marks_obtained NUMBER,
    
    CONSTRAINT fk_marks_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    CONSTRAINT fk_marks_subject
        FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
);

-- Create RESULTS Table
CREATE TABLE results (
    result_id NUMBER PRIMARY KEY,
    student_id NUMBER,
    total_marks NUMBER,
    percentage NUMBER(5,2),
    grade VARCHAR2(2),
    status VARCHAR2(10),
    rank NUMBER,

    CONSTRAINT fk_results_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);

-- Grade Calculation Function
CREATE OR REPLACE FUNCTION calculate_grade (
    p_percentage IN NUMBER
) RETURN VARCHAR2
IS
    v_grade VARCHAR2(2);
BEGIN
    IF p_percentage >= 90 THEN
        v_grade := 'A';
    ELSIF p_percentage >= 75 THEN
        v_grade := 'B';
    ELSIF p_percentage >= 60 THEN
        v_grade := 'C';
    ELSIF p_percentage >= 40 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'F';
    END IF;

    RETURN v_grade;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N/A';
END;
/
-- Result Processing Procedure
CREATE OR REPLACE PROCEDURE process_results
IS
    v_total_marks   NUMBER;
    v_max_marks     NUMBER;
    v_percentage    NUMBER(5,2);
    v_grade         VARCHAR2(2);
    v_status        VARCHAR2(10);
    v_result_id     NUMBER := 1;

    CURSOR c_students IS
        SELECT student_id FROM students;
BEGIN
    -- Clear old results (optional for re-run)
    DELETE FROM results;

    FOR stu_rec IN c_students LOOP

        -- Calculate total marks obtained by student
        SELECT SUM(marks_obtained)
        INTO v_total_marks
        FROM marks
        WHERE student_id = stu_rec.student_id;

        -- Calculate total maximum marks
        SELECT SUM(s.max_marks)
        INTO v_max_marks
        FROM subjects s
        JOIN marks m ON s.subject_id = m.subject_id
        WHERE m.student_id = stu_rec.student_id;

        -- Calculate percentage
        v_percentage := (v_total_marks / v_max_marks) * 100;

        -- Get grade using function
        v_grade := calculate_grade(v_percentage);

        -- Pass / Fail logic
        IF v_percentage >= 40 THEN
            v_status := 'PASS';
        ELSE
            v_status := 'FAIL';
        END IF;

        -- Insert into results table
        INSERT INTO results (
            result_id,
            student_id,
            total_marks,
            percentage,
            grade,
            status,
            rank
        ) VALUES (
            v_result_id,
            stu_rec.student_id,
            v_total_marks,
            v_percentage,
            v_grade,
            v_status,
            NULL
        );

        v_result_id := v_result_id + 1;

    END LOOP;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No marks found for student.');
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Maximum marks cannot be zero.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/
-- Rank Generation Procedure
CREATE OR REPLACE PROCEDURE generate_rank
IS
    v_rank NUMBER := 1;

    CURSOR c_rank IS
        SELECT result_id
        FROM results
        ORDER BY total_marks DESC;
BEGIN
    FOR r_rec IN c_rank LOOP

        UPDATE results
        SET rank = v_rank
        WHERE result_id = r_rec.result_id;

        v_rank := v_rank + 1;

    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error while generating ranks: ' || SQLERRM);
END;
/
-- Create Results View
CREATE OR REPLACE VIEW view_results AS
SELECT 
    r.rank,
    s.student_name,
    r.total_marks,
    r.percentage,
    r.grade,
    r.status
FROM results r
JOIN students s ON r.student_id = s.student_id
ORDER BY r.rank;

-- Procedure to Insert a Student
CREATE OR REPLACE PROCEDURE insert_student(
    p_student_id    IN NUMBER,
    p_student_name  IN VARCHAR2,
    p_department    IN VARCHAR2,
    p_year          IN NUMBER,
    p_email         IN VARCHAR2
)
IS
BEGIN
    INSERT INTO students(student_id, student_name, department, year, email)
    VALUES (p_student_id, p_student_name, p_department, p_year, p_email);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Student inserted successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting student: ' || SQLERRM);
END;
/
-- Insert Subjects Procedure
CREATE OR REPLACE PROCEDURE insert_subject(
    p_subject_id   IN NUMBER,
    p_subject_name IN VARCHAR2,
    p_max_marks    IN NUMBER
)
IS
BEGIN
    INSERT INTO subjects(subject_id, subject_name, max_marks)
    VALUES (p_subject_id, p_subject_name, p_max_marks);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Subject inserted successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting subject: ' || SQLERRM);
END;
/
-- Procedure to Insert Marks
CREATE OR REPLACE PROCEDURE insert_mark(
    p_mark_id       IN NUMBER,
    p_student_id    IN NUMBER,
    p_subject_id    IN NUMBER,
    p_marks_obtained IN NUMBER
)
IS
BEGIN
    INSERT INTO marks(mark_id, student_id, subject_id, marks_obtained)
    VALUES (p_mark_id, p_student_id, p_subject_id, p_marks_obtained);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Marks inserted successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inserting marks: ' || SQLERRM);
END;
/


********************************testing**********************************
SELECT * FROM students;
SELECT * FROM subjects;
SELECT * FROM marks;

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
-- Insert a Student*************
DECLARE
    v_id       NUMBER;
    v_name     VARCHAR2(50);
    v_dept     VARCHAR2(30);
    v_year     NUMBER;
    v_email    VARCHAR2(50);
BEGIN
    -- Taking input from user
    v_id := &student_id;
    v_name := '&student_name';
    v_dept := '&department';
    v_year := &year;
    v_email := '&email';

    -- Call procedure to insert student
    insert_student(v_id, v_name, v_dept, v_year, v_email);
END;
/
-- Subjects block for User Input*****************
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
-- Block to Take User Input for Marks************************
DECLARE
    v_mark_id        NUMBER;
    v_student_id     NUMBER;
    v_subject_id     NUMBER;
    v_marks_obtained NUMBER;
BEGIN
    -- Taking input from user
    v_mark_id := &mark_id;
    v_student_id := &student_id;
    v_subject_id := &subject_id;
    v_marks_obtained := &marks_obtained;

    -- Call procedure to insert marks
    insert_mark(v_mark_id, v_student_id, v_subject_id, v_marks_obtained);
END;
/

-- Test Grade Calculation Function
SELECT calculate_grade(95) AS grade FROM dual; -- Should return 'A'
SELECT calculate_grade(82) AS grade FROM dual; -- Should return 'B'
SELECT calculate_grade(65) AS grade FROM dual; -- Should return 'C'

-- Test Result Processing Procedure
-- Purpose: Ensure process_results calculates total, percentage, grade, and pass/fail correctly.
-- Expected Outcome:
-- Total marks, percentage, grade, and status are calculated correctly for all students.
-- rank column is still NULL at this stage.
BEGIN
    process_results;
END;
/
SELECT * FROM results;

-- Test Rank Generation Procedure
-- Purpose: Ensure generate_rank correctly assigns ranks based on total marks.
BEGIN
    generate_rank;
END;
/

SELECT * FROM results ORDER BY rank;


-- Test Result Publishing View
-- Purpose: Ensure the view_results correctly shows final results.
-- Expected Outcome:
-- Displays rank, student_name, total_marks, percentage, grade, status.
-- Data matches the results table.
SELECT * FROM view_results;


-- Test User Input Procedures
-- Purpose: Test inserting new data interactively.
DECLARE
BEGIN
    insert_student(104, 'Neha Kapoor', 'Computer Science', 2, 'neha@gmail.com');
END;
/

-- Insert a new subject:
DECLARE
BEGIN
    insert_subject(4, 'Data Structures', 100);
END;
/

-- Insert marks for new student:
DECLARE
BEGIN
    insert_mark(10, 104, 1, 88);
    insert_mark(11, 104, 2, 79);
    insert_mark(12, 104, 3, 92);
END;
/


-- Re-run Result Processing and Rank Generation
-- Purpose: Ensure new entries are included in results.
BEGIN
    process_results;
    generate_rank;
END;
/
SELECT * FROM view_results;


-- Exception Handling Test
-- Purpose: Check system handles errors gracefully.
-- Action Examples: Try inserting a mark for a non-existing student
BEGIN
    insert_mark(13, 999, 1, 80); -- student_id 999 does not exist
END;
/
