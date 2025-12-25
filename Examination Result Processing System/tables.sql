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
