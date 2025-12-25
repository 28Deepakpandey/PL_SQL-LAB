##  Student Result Management System (SQL / PL/SQL Project)

### 📘 1. Overview

The **Student Result Management System** is a **PL/SQL-based mini-project** designed to automate result processing in educational institutions.
It helps manage student data, subjects, marks, grades, and rankings efficiently — all within the Oracle SQL environment.

This project demonstrates the use of:

* SQL concepts: tables, constraints, joins, and views
* PL/SQL concepts: functions, procedures, cursors, exception handling, and anonymous blocks

---

###  2. Objectives

* Store and manage student, subject, and marks information.
* Automatically calculate total marks, percentage, grade, and pass/fail status.
* Generate ranks based on total marks.
* Present final results in a view for easy access.

---

###  3. Project Structure

```
student_result_system/
│
├── tables.sql          → Contains all table creation statements
├── functions.sql       → Contains grade calculation function
├── procedures.sql      → Contains all business logic procedures
├── views.sql           → Contains result publishing view
├── test_scripts.sql    → Contains test data and validation scripts
└── cleanup.sql         → Drops all objects for reset
```

---

### 🏗️ 4. Database Design and Relationships

#### 📄 (a) **STUDENTS Table**

Stores information about students.
**Columns:**

* `student_id` – Primary key
* `student_name` – Name of the student
* `department` – Department or branch
* `year` – Year of study
* `email` – Contact email

#### 📄 (b) **SUBJECTS Table**

Stores information about subjects offered.
**Columns:**

* `subject_id` – Primary key
* `subject_name` – Name of subject
* `max_marks` – Maximum marks for that subject

#### 📄 (c) **MARKS Table**

Stores marks obtained by each student in each subject.
**Columns:**

* `mark_id` – Primary key
* `student_id` – Foreign key (references STUDENTS table)
* `subject_id` – Foreign key (references SUBJECTS table)
* `marks_obtained` – Marks scored

📌 **Relation:**
Each student can have multiple marks records (one per subject).
This table forms a **many-to-many relationship** between `students` and `subjects`.

#### 📄 (d) **RESULTS Table**

Stores calculated results for each student.
**Columns:**

* `result_id` – Primary key
* `student_id` – Foreign key (references STUDENTS table)
* `total_marks` – Sum of all marks
* `percentage` – Total percentage
* `grade` – Grade based on percentage
* `status` – PASS/FAIL
* `rank` – Rank assigned after evaluation

📌 **Relation:**
`RESULTS` depends on data from `MARKS` and `SUBJECTS`.

---

###  5. Function Used

####  `calculate_grade(p_percentage IN NUMBER)`

A PL/SQL **function** that returns a grade letter based on percentage:

| Percentage | Grade |
| ---------- | ----- |
| ≥ 90       | A     |
| ≥ 75       | B     |
| ≥ 60       | C     |
| ≥ 40       | D     |
| < 40       | F     |

  Demonstrates **conditional logic** and **exception handling** in PL/SQL.

---

### 🔧 6. Procedures Used

####  `insert_student`

Inserts a new student record into the `students` table.

####  `insert_subject`

Adds a new subject into the `subjects` table.

####  `insert_mark`

Adds marks for a specific student in a specific subject.

📘 These three procedures demonstrate **basic DML operations** (INSERT) with **error handling** and **DBMS_OUTPUT** messages.

---

####  `process_results`

Main logic for calculating results:

* Uses a **cursor** to loop through each student.
* Calculates total marks and maximum possible marks.
* Calls the `calculate_grade` function.
* Determines PASS/FAIL.
* Inserts computed results into the `results` table.

📘 Demonstrates **cursors**, **aggregations**, **function calls**, and **error handling**.

---

####  `generate_rank`

Assigns ranks to students based on total marks:

* Sorts results in descending order.
* Updates the `rank` column sequentially.

📘 Demonstrates **cursor usage** and **update logic**.

---

###  7. View Used

#### `view_results`

A SQL **VIEW** combining `results` and `students`:

```sql
SELECT 
    r.rank, s.student_name, r.total_marks, r.percentage, r.grade, r.status
FROM results r
JOIN students s ON r.student_id = s.student_id
ORDER BY r.rank;
```

📘 Provides a clean final result sheet with names, marks, grades, and rank.

---

###  8. Testing and Execution Flow

Run the scripts in this order:

| Step | Script             | Purpose                                     |
| ---- | ------------------ | ------------------------------------------- |
| 1️⃣  | `tables.sql`       | Create all required tables                  |
| 2️⃣  | `functions.sql`    | Create the grade calculation function       |
| 3️⃣  | `procedures.sql`   | Create all insert and processing procedures |
| 4️⃣  | `views.sql`        | Create the final results view               |
| 5️⃣  | `test_scripts.sql` | Insert sample data and test all modules     |
| 6️⃣  | `cleanup.sql`      | Drop all objects to reset environment       |

---

###  9. Example Workflow

1. Insert students and subjects (manually or using `insert_student` & `insert_subject`).
2. Insert marks for each student using `insert_mark`.
3. Run `process_results` to calculate totals, percentages, and grades.
4. Run `generate_rank` to assign ranks.
5. Query `view_results` to see the final ranked list of students.

---

###  10. Exception Handling Demonstration

Each procedure includes exception blocks to handle:

* Duplicate entry errors
* Missing data errors
* Division by zero
* Any unexpected issue using `WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(...)`

This ensures the system runs smoothly even with invalid inputs.

---

###  11. Cleanup Script

Use `cleanup.sql` to safely drop all objects and reset the environment.
It includes error handling so you can run it multiple times without errors.

---

###  12. Key PL/SQL Concepts Demonstrated

| Concept              | Example Used                                         |
| -------------------- | ---------------------------------------------------- |
| Tables & Constraints | `students`, `subjects`, `marks`, `results`           |
| Foreign Keys         | Link between `marks` and `students/subjects`         |
| Function             | `calculate_grade`                                    |
| Procedures           | `insert_student`, `process_results`, `generate_rank` |
| Cursor               | Used inside `process_results` and `generate_rank`    |
| Exception Handling   | All procedures                                       |
| COMMIT               | Inside every DML operation                           |
| View                 | `view_results`                                       |
| Anonymous Block      | Used in `test_scripts.sql`                           |

---

### 🏁 13. Summary

The **Student Result Management System** shows how SQL and PL/SQL work together:

* **SQL** defines structure (tables, constraints, view).
* **PL/SQL** adds intelligence (procedures, function, error control).
* **Result:** A simple, modular, and automated academic result calculator.
