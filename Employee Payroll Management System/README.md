
#  Employee Payroll Management System (SQL / PL/SQL Project)

##  1. Overview

The **Employee Payroll Management System** is a PL/SQL-based mini-project designed to automate payroll tasks in an organization.

It helps HR departments to:

* Manage employee and department data.
* Calculate monthly salaries automatically.
* Generate salary reports and payslips.
* Maintain audit logs for salary and employee changes.

This project demonstrates **real-world use of SQL and PL/SQL**, including **tables, sequences, packages, procedures, functions, triggers, and cursors**.

---

##  2. Objectives

* Efficiently manage **employee and department information**.
* Automate monthly salary computation: **Basic + HRA + Bonus − Tax**.
* Generate **monthly salary reports** department-wise.
* Track **salary and employee changes** automatically using triggers.
* Demonstrate key **PL/SQL features**: Packages, Procedures, Functions, Cursors, Triggers, and Sequences.

---

##  3. Database Design

###  Tables and Relationships

| Table Name           | Purpose                            | Key Fields                      | Relationship            |
| -------------------- | ---------------------------------- | ------------------------------- | ----------------------- |
| **departments**      | Stores department info             | `dept_id` (PK)                  | 1 → many employees      |
| **employees**        | Employee details                   | `emp_id` (PK), `dept_id` (FK)   | 1 → many salary records |
| **salary_details**   | Stores salary for each month       | `salary_id` (PK), `emp_id` (FK) | many → 1 employees      |
| **salary_audit_log** | Tracks salary changes              | `audit_id` (PK)                 | Trigger-generated       |
| **emp_audit**        | Logs employee insert/update/delete | `emp_id`                        | Trigger-generated       |

### 🔗 Conceptual ER Diagram

```
departments (1) ───<M> employees (1) ───<M> salary_details
                         │
                         ├───< emp_audit (trigger)
                         └───< salary_audit_log (trigger)
```

---

##  4. PL/SQL Components

| Type       | Name / Object                                                          | Description                                         |
| ---------- | ---------------------------------------------------------------------- | --------------------------------------------------- |
| Package    | `payroll_pkg`                                                          | Groups all payroll procedures & functions           |
| Function   | `tax_calculation(p_salary)`                                            | Calculates tax based on salary slab                 |
| Procedure  | `calculate_salary(p_emp_id, p_month)`                                  | Calculates salary and inserts into `salary_details` |
| Procedure  | `monthly_report(p_month)`                                              | Displays monthly salary report using cursor         |
| Procedures | `add_department`, `add_employee`, `update_employee`, `delete_employee` | Manage department and employee records              |
| Trigger    | `audit_salary_changes`                                                 | Logs old/new salary when net salary is updated      |
| Trigger    | `trg_emp_audit`                                                        | Logs insert, update, delete actions on employees    |
| Sequence   | `salary_seq`                                                           | Generates unique salary IDs                         |

---

##  5. Major Operations

| Operation                | Description                                     | Tables / Objects                                                     |
| ------------------------ | ----------------------------------------------- | -------------------------------------------------------------------- |
| Employee Management      | Add, update, delete employee records            | `employees`, `payroll_pkg` procedures                                |
| Salary Calculation       | Computes salary = Basic + HRA + Bonus − Tax     | `employees`, `salary_details`, `calculate_salary`, `tax_calculation` |
| Monthly Report           | Shows salary report for a month                 | `monthly_report` procedure, cursor                                   |
| Department Salary Report | Shows total payroll per department              | `departments`, `employees`, `salary_details`                         |
| Salary Auditing          | Automatically logs salary changes               | Trigger `audit_salary_changes`, `salary_audit_log`                   |
| Employee Auditing        | Automatically logs insert/update/delete actions | Trigger `trg_emp_audit`, `emp_audit`                                 |

---

##  6. Workflow

1. **Add Department** → Stored in `departments`.
2. **Add Employee** → Stored in `employees`.
3. **Calculate Salary** → `calculate_salary` procedure computes salary:

   * HRA = 20% of basic, Bonus = 10% of basic
   * Calls `tax_calculation` for tax
   * Inserts result into `salary_details`
4. **Salary Change Trigger** → `audit_salary_changes` logs updates to `net_salary`.
5. **Generate Monthly Report** → `monthly_report` displays salaries using a cursor.
6. **Employee Action Trigger** → `trg_emp_audit` logs insert/update/delete actions on employees.

---

##  7. Sample Outputs

**Monthly Report**

| Employee Name | Department | Net Salary |
| ------------- | ---------- | ---------- |
| Deepak Pandey | HR         | 42000      |
| Priya Singh   | IT         | 56000      |
| Rohit Sharma  | Finance    | 32000      |

**Salary Audit Log**

| Salary_ID | Old_Net_Salary | New_Net_Salary | Changed_On  |
| --------- | -------------- | -------------- | ----------- |
| 1         | 42000          | 47000          | 23-DEC-2025 |

**Employee Audit Log**

| Emp_ID | Action | Action_Date |
| ------ | ------ | ----------- |
| 101    | INSERT | 23-DEC-2025 |
| 101    | UPDATE | 23-DEC-2025 |
| 101    | DELETE | 23-DEC-2025 |

---

##  8. Advantages

* **Modular Design** – Organized with PL/SQL packages for maintainability.
* **Data Integrity** – Enforced with triggers and constraints.
* **Automation** – Automatic salary computation and reports.
* **Transparency** – Audit logs for salary and employee actions.
* **SQL + PL/SQL Integration** – Combines database design, business logic, and automation.

---

## 📂 9. Folder Structure (Final)

```
payroll_project/
│
├── README.md                   # Project overview and instructions
│
├── drop_cleanup/               # Scripts to drop objects
│   ├── drop.sql
│   
│   
│   
│  
│
├── tables/
│   └── tables.sql              # All CREATE TABLE statements
│
├── sequences/
│   └── sequences.sql           # All CREATE SEQUENCE statements
│
├── packages/
│   ├── payroll_pkg_spec.sql    # Package specification
│   └── payroll_pkg_body.sql    # Package body (procedures & function)
│
├── triggers/
│   └── audit_triggers.sql      # All triggers
│
├── test_scripts/
│   ├── test_departments.sql    # Test scripts for adding departments
│   ├── test_employees.sql      # Test scripts for adding employees
│   ├── test_salary_calculation.sql  # Salary calculation & report
│   ├── test_update_delete_employee.sql # Update & delete employees
│   └── test_audit_triggers.sql # Test audit triggers
```
