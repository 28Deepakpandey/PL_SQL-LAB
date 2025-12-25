-- insert_student
-- insert_subject
-- insert_mark
-- process_results
-- process_results
-- generate_rank

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
