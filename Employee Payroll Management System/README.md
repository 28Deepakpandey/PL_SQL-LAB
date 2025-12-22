# 🏢 Employee Payroll Management System (SQL / PL/SQL Project)

## 📘 1. Overview
The **Employee Payroll Management System** is a PL/SQL-based mini-project designed to automate payroll processes in an organization.

It enables HR departments to manage employee information, calculate monthly salaries, generate payslips, track department-wise salary reports, and maintain salary audit logs efficiently within an Oracle SQL environment.

This project demonstrates real-time integration of SQL and PL/SQL features — including **packages, procedures, functions, cursors, triggers, and sequences** — to develop a modular, secure, and fully automated payroll solution.

---

## 🎯 2. Objectives
* To manage employee and department data efficiently.
* To automate monthly salary computation (Basic + HRA + Bonus − Tax).
* To generate monthly payslips and salary reports department-wise.
* To ensure transparency by auditing salary changes automatically.
* To demonstrate PL/SQL features like Packages, Functions, Cursors, and Triggers.

---

## 🧩 3. Database Design

### 🧱 Tables and Relationships
| Table Name | Purpose | Key Fields | Relationship |
| :--- | :--- | :--- | :--- |
| **departments** | Stores department information | `dept_id` (PK) | 1 → many with employees |
| **employees** | Holds employee details | `emp_id` (PK), `dept_id` (FK) | 1 → many with salary_details |
| **salary_details** | Stores monthly salary records | `salary_id` (PK), `emp_id` (FK) | many → 1 with employees |
| **salary_audit_log** | Tracks salary change history | `audit_id` (PK) | Trigger-generated |
| **emp_audit** | Logs employee data changes | `emp_id` | Trigger-generated |

### 🔗 ER Diagram (Conceptual)
```text
departments (1) ───< employees (1) ───< salary_details
                         │
                         ├───< emp_audit (trigger)
                         └───< salary_audit_log (trigger)


🧮 4. Table Structure Summary
🏢 departments
CREATE TABLE departments (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50),
    location VARCHAR2(50)
);

👩‍💼 employees
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    emp_name VARCHAR2(50),
    designation VARCHAR2(50),
    dept_id NUMBER,
    join_date DATE,
    basic_salary NUMBER,
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
);

💰 salary_details
CREATE TABLE salary_details (
    salary_id NUMBER PRIMARY KEY,
    emp_id NUMBER,
    salary_month VARCHAR2(10),
    basic NUMBER,
    hra NUMBER,
    bonus NUMBER,
    tax NUMBER,
    net_salary NUMBER,
    CONSTRAINT fk_salary_emp FOREIGN KEY (emp_id)
        REFERENCES employees(emp_id)
);

🧾 salary_audit_log
CREATE TABLE salary_audit_log (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
    salary_id NUMBER,
    old_net_salary NUMBER,
    new_net_salary NUMBER,
    changed_on DATE
);

🗂 emp_audit
CREATE TABLE emp_audit (
    emp_id NUMBER,
    action VARCHAR2(20),
    action_date DATE
);



## ⚙️ PL/SQL Components

| Type       | Name             | Description                                                   |
|------------|------------------|---------------------------------------------------------------|
| Package    | payroll_pkg      | Groups all payroll-related procedures and functions.          |
| Function   | tax_calculation(p_salary) | Calculates tax percentage based on salary slab.       |
| Procedure  | calculate_salary(p_emp_id, p_month) | Calculates employee salary and inserts into salary_details. |
| Procedure  | monthly_report(p_month) | Displays monthly salary report using a cursor.         |
| Procedures | add_department, add_employee, update_employee, delete_employee | Manage department and employee records. |
| Trigger    | audit_salary_changes | Logs old and new salary when net salary is updated.       |
| Trigger    | trg_emp_audit    | Logs insert, update, delete actions on employees table.       |
| Sequence   | salary_seq       | Generates unique salary IDs automatically.                   |



## 🧾 6. Major Operations and Their Use

| Operation                  | Description                                                   | Tables / Objects Involved                                      |
|----------------------------|---------------------------------------------------------------|----------------------------------------------------------------|
| Employee Details Management | Add, update, or delete employee records.                      | employees, payroll_pkg procedures                              |
| Salary Calculation          | Computes total salary = Basic + HRA + Bonus − Tax.            | employees, salary_details, calculate_salary, tax_calculation   |
| Monthly Payslip Generation  | Generates report of all employee salaries for a month.        | monthly_report procedure using cursor                          |
| Department-wise Salary Report | Displays total department payroll for given month.          | departments, employees, salary_details                         |
| Salary Change Auditing      | Logs salary changes automatically after update.               | Trigger audit_salary_changes, salary_audit_log                 |
| Employee Activity Audit     | Logs any insert/update/delete action on employees.            | Trigger trg_emp_audit, emp_audit                               |


## 🔁 7. Workflow (Execution Flow)

1. 🏢 **HR adds a department**  
   → Stored in **departments** table.

2. 👩‍💼 **HR adds an employee**  
   → Stored in **employees** table.

3. 💰 **Salary is calculated using `calculate_salary`**, which:  
   - Fetches **basic salary**.  
   - Computes **HRA = 20%**, **Bonus = 10%**.  
   - Calls **`tax_calculation` function** for tax deduction.  
   - Inserts final result into **salary_details**.

4. 🧾 **Trigger `audit_salary_changes`**  
   → Logs old and new salary whenever **net_salary** is updated.

5. 📊 **Procedure `monthly_report`**  
   → Displays the consolidated **monthly payroll** using a cursor.


## 📈 8. Sample Outputs

### 🧮 Monthly Report
| Employee Name   | Department | Net Salary |
|-----------------|------------|------------|
| Deepak Pandey   | HR         | 42000      |
| Priya Singh     | IT         | 56000      |
| Rohit Sharma    | Finance    | 32000      |

### 🧾 Salary Audit Log
| Salary_ID | Old_Net_Salary | New_Net_Salary | Changed_On  |
|-----------|----------------|----------------|-------------|
| 1         | 42000          | 47000          | 23-DEC-2025 |

### 👩‍💼 Employee Audit Log
| Emp_ID | Action  | Action_Date |
|--------|---------|-------------|
| 101    | INSERT  | 23-DEC-2025 |
| 101    | UPDATE  | 23-DEC-2025 |
| 101    | DELETE  | 23-DEC-2025 |


## 📊 9. Advantages

- 🧩 **Modular Design** – Organized through PL/SQL packages for better maintainability and scalability.  
- 🔒 **Data Integrity** – Enforced with triggers and constraints to ensure consistency.  
- ⚡ **Automation** – Provides automatic salary computation and report generation.  
- 🧾 **Transparency** – Maintains audit logs for salary and employee actions.  
- 🔗 **Integration** – Demonstrates full SQL + PL/SQL integration in a single project.  

---

## ✅ 10. Conclusion

The **Employee Payroll Management System** demonstrates the practical application of PL/SQL in corporate payroll management.  
It streamlines HR operations, automates salary calculations, and secures data with auditing mechanisms.  

This mini‑project highlights how **database programming, business logic, and automation** can be integrated to build a complete and efficient enterprise system.
