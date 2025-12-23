# 📘 1. Overview

The **Online Examination Result Processing System** is a **PL/SQL-based mini-project** designed to automate the result generation process in educational institutions.  

### 🎯 Key Objectives
- Automate student result calculation and publishing.  
- Minimize manual errors in grading and ranking.  
- Ensure transparent and efficient result management.  

### 🧩 Core Features
- Store and manage student marks across multiple subjects.  
- Automatic grade calculation based on predefined score ranges.  
- Pass/Fail logic implementation using conditional checks.  
- Rank generation using PL/SQL cursors for sorting and comparison.  
- Result publishing with real-time status updates.  

### ⚙️ Technology Stack
- **Oracle SQL / PL/SQL**  
- Tables, Procedures, Functions, Triggers, Sequences  
- Cursor-based ranking and auditing mechanisms  

## 🎯 2. Objectives
- ⚡ Automate student result calculation and publishing.  
- ✅ Minimize manual errors in grading and ranking.  
- 🔍 Ensure transparent and efficient result management.  

---

## 🧩 3. Key Features
- 📚 Store and manage student marks across multiple subjects.  
- 🧮 Automatic grade calculation based on predefined score ranges.  
- ✔️ Pass/Fail logic implementation using conditional checks.  
- 🏆 Rank generation using PL/SQL cursors for sorting and comparison.  
- 📢 Result publishing with real-time status updates.  


## 🧱 Database Design

### ➤ Tables Created

| Table    | Purpose                                      | Key Fields                                                   |
|----------|----------------------------------------------|--------------------------------------------------------------|
| students | Store student personal info                  | student_id, student_name, department, year, email            |
| subjects | Store subject details and max marks          | subject_id, subject_name, max_marks                          |
| marks    | Store marks obtained by each student/subject | mark_id, student_id, subject_id, marks_obtained              |
| results  | Store final computed results                 | result_id, student_id, total_marks, percentage, grade, status, rank |

---

**Design principle used:**  
Normalization up to **3NF** — each table has atomic data, and foreign key relationships maintain referential integrity.


## ⚙️ Step 4: Relationships (Foreign Keys)

| Relationship              | References                        | Purpose                                      |
|---------------------------|-----------------------------------|----------------------------------------------|
| marks.student_id          | students.student_id               | Links marks to the correct student.          |
| marks.subject_id          | subjects.subject_id               | Links marks to the correct subject.          |
| results.student_id        | students.student_id               | Links results to the correct student.        |

✅ Ensures **data consistency** and **referential integrity** between related tables.

---

## 🧩 Step 5: Function — `calculate_grade`

**Purpose:**  
Encapsulate grade calculation logic for reusability.

**Logic:**

| Range        | Grade |
|--------------|-------|
| 90 and above | A     |
| 75–89        | B     |
| 60–74        | C     |
| 40–59        | D     |
| Below 40     | F     |

**Usage:**  
Called inside the `process_results` procedure to assign grades automatically.



## 🛠️ Step 6: Procedure — process_results
- 🔄 Loop through each student using a **cursor**  
- 📊 Fetch **total marks obtained** by that student  
- 📚 Calculate **maximum possible marks**  
- 🧮 Compute **percentage = (total_obtained / total_max) * 100**  
- 🏷️ Call **calculate_grade** function for grade assignment  
- ✔️ Determine **PASS/FAIL** using percentage  
- 🗂 Insert computed result into **results** table  
- ⚠️ Handle exceptions like division by zero or missing data  

---

### ✅ Important Concepts Used
- 🔄 Cursor iteration  
- ➕ Aggregation (`SUM`)  
- 📞 Function calling inside procedure  
- ⚠️ Exception handling  

---

## 🛠️ Step 7: Procedure — generate_rank
- 🎯 Assign ranks to students based on **total marks**  
- 📂 Open a **cursor** sorted by `total_marks DESC`  
- 🔢 Assign `rank = 1`, increment for each record  
- 🗂 Update the **results** table accordingly  

✅ **Concept Used:**  
- 📌 Explicit Cursor  
- 🔄 Sequential Update  
- 📊 Ordered Ranking  

---

## 🧩 Step 8: View — view_results
- 🎯 **Purpose:** Create a read-only display combining `students` and `results` tables  
- 📑 **Displayed Columns:**  
  - 🏆 rank  
  - 👤 student_name  
  - 📊 total_marks  
  - 🧮 percentage  
  - 🏷️ grade  
  - ✔️ status  
- ✅ **Advantage:** Makes result publishing easier — a single query can display all final results neatly  


## 🧩 Step 9: Data Entry Procedures
- 👤 **insert_student** → Simplifies inserting a student record with validation and commit  
- 📘 **insert_subject** → Adds a new subject with max marks  
- ✏️ **insert_mark** → Adds marks for each student-subject combination  

✅ **Benefit:**  
Encapsulation of `INSERT` logic improves data safety and code reusability  

---

## 🧪 Step 9: Testing Steps
- 🗂️ **Insert Sample Data** → Use the provided block or interactive input (`&student_id`, etc.) to add students, subjects, and marks  
- 🧪 **Test Function**
- sql
SELECT calculate_grade(82) FROM dual;


3️⃣ Run Result Processing
BEGIN
    process_results;
END;

4️⃣ Generate Ranks
BEGIN
    generate_rank;
END;

5️⃣ View Final Results
SELECT * FROM view_results;
## ✅ Expected Output Example

| Rank | Student Name  | Total Marks | Percentage | Grade | Status |
|------|---------------|-------------|------------|-------|--------|
| 1    | Karan Singh   | 275         | 91.6       | A     | PASS   |
| 2    | Rahul Sharma  | 253         | 84.3       | B     | PASS   |
| 3    | Anita Verma   | 205         | 68.3       | C     | PASS   |


---

## 🛡️ Step 10: Exception Handling
- ⚙️ Handled in all procedures to ensure smooth execution  
- ❌ **NO_DATA_FOUND** → Missing marks  
- ➗ **ZERO_DIVIDE** → Incorrect max marks  
- 🛑 **OTHERS** → Catch-all for unexpected errors  

📢 Displayed using:  
``sql
DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);


## 🧩 Step 11: Verification Queries
- 🎯 **Purpose:** Run quick checks to validate data and results  
- 📑 **Queries:**  
  - 👤 View Students → `SELECT * FROM students;`  
  - 📘 View Subjects → `SELECT * FROM subjects;`  
  - ✏️ View Marks → `SELECT * FROM marks;`  
  - 📊 View Processed Results → `SELECT * FROM results;`  
  - 🏆 Final Published View → `SELECT * FROM view_results;`  
