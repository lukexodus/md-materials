# Indexes

## Clustered vs Non-Clustered Indexes

### Clustered Index

A **clustered index** determines the physical order of data storage in a table. Think of it like a dictionary where words are physically arranged alphabetically.

**Key characteristics:**
- The table's rows are stored on disk in the same order as the clustered index
- Only **one** clustered index per table (because data can only be physically sorted one way)
- The leaf nodes of the index contain the actual data rows
- Typically created on the primary key by default in most database systems
- Fast for range queries on the indexed column(s)

**Example:** If you have a clustered index on `EmployeeID`, records with IDs 1, 2, 3 are physically stored in that order on disk.

### Non-Clustered Index

A **non-clustered index** is a separate structure that maintains pointers to the actual data. Think of it like a book's index that points to page numbers.

**Key characteristics:**
- Stored separately from the table data
- Can have **multiple** non-clustered indexes per table
- The leaf nodes contain pointers (row locators) to the actual data rows
- Requires an extra lookup step: index → data location → actual data
- Slightly slower than clustered indexes for individual lookups due to the extra step
- Essential for foreign keys to speed up joins

**Example:** A non-clustered index on `LastName` creates a separate sorted structure pointing to where each employee's full record is stored.

When you join tables on foreign keys, the database needs to quickly find matching rows. Without an index on the foreign key column, the database performs a full table scan. A non-clustered index on the foreign key column allows the database to quickly locate matching rows, dramatically improving join performance.

---

# Normalization

**Normalization** is a database design technique used to reduce redundancy and ensure data integrity. It involves organizing data into related tables and applying certain rules called **normal forms** (NF). Here are the first three normal forms, which are commonly applied in database design:

### 1. **First Normal Form (1NF)**
- **Rule**: 
  - All attributes (columns) must contain **atomic values** (no repeating groups or sets).
  - There must be no duplicate rows (every row should be unique).
  
- **Objective**: Eliminate **repeating groups** by ensuring each cell holds a single value.

#### Example:
| CustomerID | PhoneNumber       |
|------------|-------------------|
| 1          | 12345, 67890      |

This violates **1NF** because a single cell contains multiple values. After normalization:

| CustomerID | PhoneNumber |
|------------|-------------|
| 1          | 12345       |
| 1          | 67890       |

---

### 2. **Second Normal Form (2NF)**
- **Rule**:
  - The table must first satisfy **1NF**.
  - Every **non-key attribute** must be **fully dependent** on the entire primary key, not just a part of it.

- **Objective**: Eliminate **partial dependencies** where non-key attributes depend on only part of a composite primary key.

#### Example:
In the following table, the `Address` depends only on `StudentID` and not on the full composite key (`StudentID`, `CourseID`), violating 2NF.

| StudentID | CourseID | Address  |
|-----------|----------|----------|
| 1         | 101      | Address1 |
| 1         | 102      | Address1 |

To satisfy **2NF**, we split the table into:

**Student Table**:

| StudentID | Address  |
| --------- | -------- |
| 1         | Address1 |
|           |          |

**StudentCourse Table**:

| StudentID | CourseID |
|-----------|----------|
| 1         | 101      |
| 1         | 102      |

---

### 3. **Third Normal Form (3NF)**
- **Rule**:
  - The table must first satisfy **2NF**.
  - There must be **no transitive dependencies**—non-key attributes should not depend on other non-key attributes.

- **Objective**: Eliminate **transitive dependencies** where a non-key attribute depends on another non-key attribute, not directly on the primary key.

#### Example:
In the table below, `InstructorName` depends on `CourseID`, which is a non-key attribute, rather than the primary key `StudentID`.

| StudentID | CourseID | InstructorName |
|-----------|----------|----------------|
| 1         | 101      | Prof. X        |
| 2         | 101      | Prof. X        |

To satisfy **3NF**, we create two tables:

**Course Table**:

| CourseID | InstructorName |
|----------|----------------|
| 101      | Prof. X        |

**StudentCourse Table**:

| StudentID | CourseID |
|-----------|----------|
| 1         | 101      |
| 2         | 101      |

---

### Summary of Normal Forms:
| Normal Form | Key Rule                           | Example Fix                                      |
| ----------- | ---------------------------------- | ------------------------------------------------ |
| **1NF**     | Atomic values, no repeating groups | Separate phone numbers into individual rows      |
| **2NF**     | Eliminate partial dependencies     | Separate `Address` from composite key table      |
| **3NF**     | Eliminate transitive dependencies  | Create separate `Instructor` and `Course` tables |

This process ensures a well-structured, efficient, and less redundant database design.

---

# Joins

## Cartesian Products Applications

**Multiplying tables**, also known as taking the **Cartesian product**, is a mathematical operation where every row from one table is combined with every row from another table. In databases, this is the result of a **CROSS JOIN**, though it's often used indirectly in **JOIN** operations. While Cartesian products aren't always useful on their own due to the large number of combinations, they have several important applications in database operations and queries.

Here are some common uses of multiplying tables (Cartesian product):

### 1. **Generating All Possible Combinations**
- **Description**: Cartesian products can be used to generate all possible combinations of rows from two or more tables.
- **Use Case**: For example, if you have a table of `Products` and a table of `Colors`, a Cartesian product would give you every possible color for each product, useful in scenarios like generating variations for e-commerce products.
  
#### Example:
**Products Table**:

| ProductID | ProductName |
|-----------|-------------|
| 1         | Shirt       |
| 2         | Pants       |

**Colors Table**:

| ColorID | ColorName |
|---------|-----------|
| A       | Red       |
| B       | Blue      |

**Cartesian Product (Products × Colors)**:

| ProductID | ProductName | ColorID | ColorName |
|-----------|-------------|---------|-----------|
| 1         | Shirt       | A       | Red       |
| 1         | Shirt       | B       | Blue      |
| 2         | Pants       | A       | Red       |
| 2         | Pants       | B       | Blue      |

### 2. **Data Analysis**
- **Description**: Cartesian products can be used in statistical analysis or data modeling where combinations of data points from two different datasets need to be evaluated.
- **Use Case**: If you're comparing every possible pair of data points from two different datasets to check for correlations or analyze patterns, the Cartesian product can help. For example, comparing sales in different regions against different marketing strategies.

### 3. **Join Operations in Queries**
- **Description**: The Cartesian product is at the core of **JOIN** operations. A JOIN is essentially a Cartesian product that filters out irrelevant combinations, keeping only rows where certain conditions are met.
- **Use Case**: In an **INNER JOIN**, a Cartesian product is generated and then filtered based on matching values between the tables (such as a common `ID`).

#### Example (INNER JOIN):
If we have:
**Orders Table**:

| OrderID | CustomerID |
|---------|------------|
| 1       | 100        |
| 2       | 101        |

**Customers Table**:

| CustomerID | CustomerName |
|------------|--------------|
| 100        | John Doe     |
| 101        | Jane Smith   |

An **INNER JOIN** would conceptually create a Cartesian product first:

| OrderID | CustomerID | CustomerID | CustomerName |
|---------|------------|------------|--------------|
| 1       | 100        | 100        | John Doe     |
| 1       | 100        | 101        | Jane Smith   |
| 2       | 101        | 100        | John Doe     |
| 2       | 101        | 101        | Jane Smith   |

Then, it filters out the rows where `CustomerID` matches on both sides:

| OrderID | CustomerID | CustomerName |
|---------|------------|--------------|
| 1       | 100        | John Doe     |
| 2       | 101        | Jane Smith   |

### 4. **Testing or Debugging Queries**
- **Description**: A Cartesian product can sometimes be used in testing queries to understand how different rows interact with one another when no filtering conditions are applied.
- **Use Case**: When debugging a query or checking the logic of joins, a Cartesian product can help visualize how rows combine before applying conditions, revealing any issues in the JOIN logic.

### 5. **Scheduling or Assignment Problems**
- **Description**: Cartesian products can be useful in situations like task scheduling or assignment problems, where every combination of tasks and resources needs to be evaluated.
- **Use Case**: For example, generating a schedule where each employee is matched with all available shifts for a given week.

### 6. **Exploring Potential Relationships**
- **Description**: In exploratory data analysis, taking a Cartesian product can help identify potential relationships between datasets when you are unsure of the exact matching conditions.
- **Use Case**: If you're analyzing customer behavior and you want to compare each customer with every product to explore purchase likelihood or interest patterns, a Cartesian product would generate all possible interactions.

### Caution:
- **Large Output Size**: The main drawback of the Cartesian product is that it can create a massive number of rows. If one table has $m$ rows and another has $n$ rows, the Cartesian product will have $m \times n$ rows, which can lead to performance issues in large datasets.

### Summary of Uses:
| Use Case                         | Description                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------|
| **Generating Combinations**       | Create all possible combinations of rows from two tables (e.g., products/colors) |
| **Data Analysis**                 | Analyze or compare different sets of data points (e.g., correlations)       |
| **Join Operations**               | A core part of filtering rows in JOINs (e.g., INNER JOIN)                   |
| **Testing/Debugging**             | Visualize data interactions before applying conditions in a query           |
| **Scheduling/Assignments**        | Solve scheduling and assignment problems by exploring all combinations      |
| **Exploring Relationships**       | Evaluate potential interactions between different sets of data              |

The **Cartesian product** is fundamental in relational databases, though it’s typically paired with filters to avoid overwhelming results in large datasets.

---

## INNER JOIN vs LEFT JOIN

### What They Do

**INNER JOIN** returns only rows where matching values exist in **both** tables.

**LEFT JOIN** (or LEFT OUTER JOIN) returns **all** rows from the left table, plus matching rows from the right table. When no match exists, the right table's columns contain NULL.

### Visual Example

Suppose we have two tables:

**Customers:**
```
customer_id | name
------------|-------
1           | Alice
2           | Bob
3           | Carol
```

**Orders:**
```
order_id | customer_id | amount
---------|-------------|-------
101      | 1           | 50
102      | 1           | 75
103      | 3           | 30
```

#### INNER JOIN Result
```sql
SELECT c.name, o.order_id, o.amount
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;
```

Returns only customers **with orders**:
```
name  | order_id | amount
------|----------|-------
Alice | 101      | 50
Alice | 102      | 75
Carol | 103      | 30
```
Bob is excluded because he has no orders.

#### LEFT JOIN Result
```sql
SELECT c.name, o.order_id, o.amount
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id;
```

Returns **all customers**, with NULLs where no orders exist:
```
name  | order_id | amount
------|----------|-------
Alice | 101      | 50
Alice | 102      | 75
Bob   | NULL     | NULL
Carol | 103      | 30
```

### When to Use Each

**Use INNER JOIN when:**
- You only want records that have matching data in both tables
- Missing relationships should exclude records from results
- Example: "Show all orders with their customer details"

**Use LEFT JOIN when:**
- You want all records from one table, regardless of matches
- You need to identify records without matches (NULLs are meaningful)
- Example: "Show all customers, including those who haven't placed orders"

### Key Difference

The fundamental difference is how they handle non-matching rows:
- **INNER JOIN**: Excludes them entirely
- **LEFT JOIN**: Keeps left table rows, fills right table columns with NULL

---

# Query Optimization

## EXISTS vs IN for Subqueries

### Performance Differences

**EXISTS** and **IN** can produce different execution plans, though modern query optimizers often handle them similarly:

#### EXISTS characteristics:
- Short-circuits: stops searching as soon as it finds one matching row
- Generally more efficient when the subquery returns many rows
- Better for correlated subqueries (subquery references outer query)
- Returns TRUE/FALSE, doesn't care about result set size

#### IN characteristics:
- Evaluates the entire subquery result set
- Can be more efficient when subquery returns few distinct values
- Better for uncorrelated subqueries with small result sets
- Can use indexes on the column list more effectively in some cases

### Examples

**Using EXISTS:**
```sql
SELECT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);
```

**Using IN:**
```sql
SELECT c.customer_id, c.name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id 
    FROM orders o
);
```

### When to Prefer EXISTS

1. **Large subquery results**: When the subquery might return many rows
2. **Correlated subqueries**: When the subquery references the outer query
3. **Existence checks**: When you only need to know if *any* match exists
4. **NULL handling**: EXISTS handles NULLs more predictably

### When IN Might Be Better

1. **Small, static lists**: `WHERE status IN ('active', 'pending')`
2. **Small subquery results**: Few distinct values expected
3. **Simple value matching**: Uncorrelated subqueries with good indexes

### Important Notes

[Inference] Modern database optimizers (PostgreSQL 12+, MySQL 8+, SQL Server 2019+) often transform IN to EXISTS internally when appropriate, making the difference less significant than in older systems.

[Unverified] The actual performance difference depends on:
- Database system and version
- Query optimizer sophistication
- Data distribution and indexes
- Query complexity and correlation

**Always test with your specific database and data** using EXPLAIN/EXPLAIN ANALYZE to verify which performs better in your scenario.

---

## Materialized Views for Frequently Accessed Aggregations

### What Are Materialized Views

A **materialized view** is a database object that stores the result of a query physically on disk, unlike regular views which are virtual and execute the query each time they're accessed.

### Key Characteristics

- **Pre-computed results**: Query runs once, results are stored
- **Physical storage**: Takes up disk space like a table
- **Refresh mechanism**: Must be updated (refreshed) to reflect source data changes
- **Query performance**: Fast reads since data is pre-aggregated

### When to Use Materialized Views

**Good candidates:**
- Complex aggregations (SUM, AVG, COUNT with GROUP BY)
- Multi-table joins executed frequently
- Reports run multiple times with same logic
- Dashboard queries with expensive calculations
- Data that doesn't need to be real-time accurate

**Poor candidates:**
- Frequently changing source data requiring constant refresh
- Simple queries that already perform well
- Data requiring real-time accuracy
- Storage-constrained environments

### Example

**Without materialized view:**
```sql
-- Run this expensive query every time
SELECT 
    p.category,
    DATE_TRUNC('month', o.order_date) as month,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity * oi.price) as revenue,
    AVG(oi.quantity * oi.price) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category, DATE_TRUNC('month', o.order_date);
```

**With materialized view:**
```sql
-- Create once
CREATE MATERIALIZED VIEW monthly_category_sales AS
SELECT 
    p.category,
    DATE_TRUNC('month', o.order_date) as month,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity * oi.price) as revenue,
    AVG(oi.quantity * oi.price) as avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category, DATE_TRUNC('month', o.order_date);

-- Query is now fast
SELECT * FROM monthly_category_sales 
WHERE category = 'Electronics';
```

### Refresh Strategies

**Complete refresh** (PostgreSQL):
```sql
REFRESH MATERIALIZED VIEW monthly_category_sales;
```

**Concurrent refresh** (doesn't lock view):
```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_category_sales;
```

**Scheduled refresh approaches:**
- Cron jobs or scheduled tasks
- Triggered by application events
- Automatic refresh on commit (Oracle)
- Incremental refresh (Oracle, some systems)

### Trade-offs

**Benefits:**
- Dramatic query performance improvement for complex aggregations
- Reduces load on source tables
- Consistent query response times

**Costs:**
- Additional storage space required
- Data staleness between refreshes
- Refresh operations consume resources
- Maintenance overhead

### Database Support

[Unverified] Support and syntax vary by database system:
- PostgreSQL: Full support with CONCURRENTLY option
- Oracle: Advanced refresh options including incremental
- SQL Server: Indexed views (similar concept, different implementation)
- MySQL: No native support (use triggers + tables)

**Always test refresh performance and storage requirements** with your actual data volumes before implementing in production.

---

# Functional Dependencies Practice Exercise

## Exercise 1: University Course Registration

**Relation:**
```
ENROLLMENT(StudentID, StudentName, CourseID, CourseName, InstructorID, InstructorName, 
           Semester, Grade, InstructorOffice, StudentMajor, CourseDept)
```

**Business Rules:**
1. Each student has a unique StudentID and exactly one name
2. Each student has exactly one major
3. Each course has a unique CourseID and exactly one course name
4. Each course belongs to exactly one department
5. Each instructor has a unique InstructorID, one name, and one office
6. A course is taught by one instructor per semester
7. A student receives one grade per course per semester
8. The same course can be offered in multiple semesters
9. An instructor can teach multiple courses

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 1

**Functional Dependencies:**

1. `StudentID → StudentName, StudentMajor`
2. `CourseID → CourseName, CourseDept`
3. `InstructorID → InstructorName, InstructorOffice`
4. `CourseID, Semester → InstructorID` (and transitively → InstructorName, InstructorOffice)
5. `StudentID, CourseID, Semester → Grade`

**Principles Used in Identification:**

- **Uniqueness principle**: StudentID uniquely identifies student attributes; CourseID uniquely identifies course attributes; InstructorID uniquely identifies instructor attributes
- **Composite key principle**: StudentID + CourseID + Semester forms a composite key that determines Grade
- **Temporal dependency**: CourseID + Semester determines which instructor teaches that course in that specific semester
- **Transitive dependency detection**: InstructorID → InstructorName and InstructorOffice (transitive through CourseID, Semester → InstructorID)

**Candidate Key:**
- `(StudentID, CourseID, Semester)` is the candidate key for this relation

**Normalization Analysis:**

- **1NF**: ✓ Yes - all attributes contain atomic values
- **2NF**: ✗ No - partial dependencies exist:
  - StudentName depends on only StudentID (part of the key)
  - StudentMajor depends on only StudentID (part of the key)
  - CourseName depends on only CourseID (part of the key)
  - CourseDept depends on only CourseID (part of the key)
- **3NF**: ✗ No - fails 2NF, plus transitive dependencies exist (InstructorName, InstructorOffice depend on InstructorID, which depends on CourseID + Semester)
- **BCNF**: ✗ No - fails 3NF

---

## Exercise 2: Hospital Appointments

**Relation:**
```
APPOINTMENT(PatientID, PatientName, DoctorID, DoctorName, AppointmentDate, 
            AppointmentTime, RoomNumber, DoctorSpecialty, PatientPhone)
```

**Business Rules:**
1. Each patient has a unique PatientID, one name, and one phone number
2. Each doctor has a unique DoctorID, one name, and one specialty
3. Each appointment is scheduled for one specific date and time
4. A doctor can see only one patient at a given date and time
5. A patient can have only one appointment at a given date and time
6. A room is assigned to each appointment
7. Multiple appointments can occur in the same room on different dates/times

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 2

**Functional Dependencies:**

1. `PatientID → PatientName, PatientPhone`
2. `DoctorID → DoctorName, DoctorSpecialty`
3. `DoctorID, AppointmentDate, AppointmentTime → PatientID, RoomNumber` (and transitively → PatientName, PatientPhone)
4. `PatientID, AppointmentDate, AppointmentTime → DoctorID, RoomNumber` (and transitively → DoctorName, DoctorSpecialty)

**Principles Used in Identification:**

- **Uniqueness principle**: PatientID and DoctorID uniquely determine their respective attributes
- **Mutual exclusivity**: Either (DoctorID + Date + Time) OR (PatientID + Date + Time) can serve as determinants
- **Multiple candidate keys**: This relation has two candidate keys, indicating different ways to uniquely identify appointments
- **Transitive dependency**: Doctor and Patient attributes flow transitively through their respective IDs

**Candidate Keys:**
- `(DoctorID, AppointmentDate, AppointmentTime)`
- `(PatientID, AppointmentDate, AppointmentTime)`

**Normalization Analysis:**

- **1NF**: ✓ Yes - all attributes are atomic
- **2NF**: ✗ No - partial dependencies exist:
  - PatientName, PatientPhone depend on only PatientID
  - DoctorName, DoctorSpecialty depend on only DoctorID
- **3NF**: ✗ No - fails 2NF
- **BCNF**: ✗ No - fails 3NF

---

## Exercise 3: Library Book Loans

**Relation:**
```
LOAN(BookCopy, ISBN, BookTitle, BorrowerID, BorrowerName, LoanDate, 
     DueDate, AuthorName, PublisherName)
```

**Business Rules:**
1. Each ISBN identifies a unique book title
2. A book (identified by ISBN) has one author and one publisher
3. Multiple physical copies exist for each book (BookCopy uniquely identifies each physical copy)
4. Each BookCopy corresponds to exactly one ISBN
5. A book copy can be loaned to only one borrower at a time
6. Each borrower has a unique BorrowerID and one name
7. The loan period is 14 days (DueDate = LoanDate + 14 days)
8. BookCopy is currently on loan in this relation (only active loans are recorded)

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 3

**Functional Dependencies:**

1. `ISBN → BookTitle, AuthorName, PublisherName`
2. `BookCopy → ISBN` (and transitively → BookTitle, AuthorName, PublisherName)
3. `BorrowerID → BorrowerName`
4. `BookCopy → BorrowerID, LoanDate` (and transitively → BorrowerName)
5. `LoanDate → DueDate` (since DueDate is computed as LoanDate + 14 days)
6. `BookCopy → DueDate` (transitively through LoanDate)

**Principles Used in Identification:**

- **Hierarchical dependency**: BookCopy → ISBN → Book attributes (multi-level transitive)
- **Single determinant**: BookCopy alone determines all other attributes (since this tracks only current/active loans)
- **Computed attributes**: DueDate functionally depends on LoanDate through a formula
- **Transitive chains**: Multiple levels of transitivity exist (BookCopy → ISBN → BookTitle)

**Candidate Key:**
- `BookCopy` (single attribute key, since each copy can have only one active loan)

**Normalization Analysis:**

- **1NF**: ✓ Yes - atomic values only
- **2NF**: ✓ Yes - no partial dependencies (single-attribute key means this is automatically satisfied)
- **3NF**: ✗ No - transitive dependencies exist:
  - BookCopy → ISBN → BookTitle, AuthorName, PublisherName
  - BookCopy → BorrowerID → BorrowerName
  - BookCopy → LoanDate → DueDate
- **BCNF**: ✗ No - fails 3NF, and ISBN is a determinant but not a superkey

---

## Exercise 4: Employee Project Assignment

**Relation:**
```
ASSIGNMENT(EmployeeID, EmployeeName, ProjectID, ProjectName, HoursWorked, 
           DepartmentID, DepartmentName, ProjectManager, ManagerPhone, EmployeeSalary)
```

**Business Rules:**
1. Each employee has a unique EmployeeID, one name, and one salary
2. Each employee belongs to exactly one department
3. Each department has a unique DepartmentID and one department name
4. Each project has a unique ProjectID, one project name, and one project manager
5. Each project manager has one phone number
6. An employee can work on multiple projects
7. A project can have multiple employees assigned
8. HoursWorked represents the hours an employee has worked on a specific project
9. The same person who is a project manager on one project may be an employee on another

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 4

**Functional Dependencies:**

1. `EmployeeID → EmployeeName, DepartmentID, EmployeeSalary` (and transitively → DepartmentName)
2. `DepartmentID → DepartmentName`
3. `ProjectID → ProjectName, ProjectManager` (and transitively → ManagerPhone)
4. `ProjectManager → ManagerPhone`
5. `EmployeeID, ProjectID → HoursWorked`

**Principles Used in Identification:**

- **Entity identification**: EmployeeID, DepartmentID, and ProjectID each identify distinct entities with their own attributes
- **Composite key necessity**: Hours worked requires both EmployeeID and ProjectID to be determined (many-to-many relationship)
- **Transitive dependency chains**: 
  - EmployeeID → DepartmentID → DepartmentName
  - ProjectID → ProjectManager → ManagerPhone
- **Partial dependency detection**: Single-key attributes (EmployeeName, ProjectName) depend on only part of the composite key

**Candidate Key:**
- `(EmployeeID, ProjectID)` is the candidate key

**Normalization Analysis:**

- **1NF**: ✓ Yes - all attributes are atomic
- **2NF**: ✗ No - partial dependencies exist:
  - EmployeeName, DepartmentID, EmployeeSalary depend on only EmployeeID
  - ProjectName, ProjectManager depend on only ProjectID
- **3NF**: ✗ No - fails 2NF, plus transitive dependencies (DepartmentName via DepartmentID, ManagerPhone via ProjectManager)
- **BCNF**: ✗ No - fails 3NF

---

## Exercise 5: Restaurant Orders

**Relation:**
```
ORDER_DETAIL(OrderID, OrderDate, TableNumber, WaiterID, WaiterName, 
             ItemID, ItemName, Quantity, ItemPrice, CustomerCount)
```

**Business Rules:**
1. Each order has a unique OrderID and occurs on one date
2. Each order is associated with one table and served by one waiter
3. Each table can have multiple orders throughout the day (different OrderIDs)
4. Each waiter has a unique WaiterID and one name
5. An order can contain multiple items
6. Each item has a unique ItemID, one name, and one price
7. Quantity represents how many of that item were ordered in that specific order
8. CustomerCount represents the number of customers at the table for that order
9. The same item can appear in multiple orders

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 5

**Functional Dependencies:**

1. `OrderID → OrderDate, TableNumber, WaiterID, CustomerCount` (and transitively → WaiterName)
2. `WaiterID → WaiterName`
3. `ItemID → ItemName, ItemPrice`
4. `OrderID, ItemID → Quantity`

**Principles Used in Identification:**

- **Order-level attributes**: OrderID determines attributes that apply to the entire order (date, table, waiter, customer count)
- **Item-level attributes**: ItemID determines attributes that apply to the menu item regardless of order
- **Intersection attributes**: Quantity exists only at the intersection of Order and Item (many-to-many relationship attribute)
- **Transitive dependency**: WaiterName depends on WaiterID, which depends on OrderID

**Candidate Key:**
- `(OrderID, ItemID)` is the candidate key

**Normalization Analysis:**

- **1NF**: ✓ Yes - atomic values throughout
- **2NF**: ✗ No - partial dependencies exist:
  - OrderDate, TableNumber, WaiterID, CustomerCount depend on only OrderID
  - ItemName, ItemPrice depend on only ItemID
- **3NF**: ✗ No - fails 2NF, plus transitive dependency (OrderID → WaiterID → WaiterName)
- **BCNF**: ✗ No - fails 3NF

---

## Exercise 6: Student Advisor Meetings

**Relation:**
```
MEETING(StudentID, AdvisorID, MeetingDate, MeetingTime, Location, 
        StudentMajor, AdvisorDepartment, AdvisorOffice, MeetingNotes)
```

**Business Rules:**
1. Each student has a unique StudentID and one major
2. Each advisor has a unique AdvisorID, belongs to one department, and has one office
3. A student can meet with an advisor multiple times
4. An advisor can meet with multiple students
5. Each meeting occurs at a specific date and time in a specific location
6. An advisor can have only one meeting at a given date and time
7. A student can have only one meeting at a given date and time
8. Meeting notes are specific to each individual meeting

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 6

**Functional Dependencies:**

1. `StudentID → StudentMajor`
2. `AdvisorID → AdvisorDepartment, AdvisorOffice`
3. `StudentID, AdvisorID, MeetingDate, MeetingTime → Location, MeetingNotes`
4. `AdvisorID, MeetingDate, MeetingTime → StudentID, Location, MeetingNotes` (and transitively → StudentMajor)
5. `StudentID, MeetingDate, MeetingTime → AdvisorID, Location, MeetingNotes` (and transitively → AdvisorDepartment, AdvisorOffice)

**Principles Used in Identification:**

- **Multiple candidate key analysis**: Three possible candidate keys exist, each representing a different constraint
- **Temporal constraints**: Date + Time combinations with either StudentID or AdvisorID create unique identifiers
- **Minimality testing**: All four attributes (StudentID, AdvisorID, MeetingDate, MeetingTime) together form a superkey, but not a minimal candidate key
- **Transitive dependencies**: Entity attributes (StudentMajor, AdvisorDepartment, AdvisorOffice) depend transitively through their respective IDs

**Candidate Keys:**
- `(StudentID, AdvisorID, MeetingDate, MeetingTime)` - primary choice
- `(AdvisorID, MeetingDate, MeetingTime)` - alternate (advisor can have only one meeting at a time)
- `(StudentID, MeetingDate, MeetingTime)` - alternate (student can have only one meeting at a time)

[Inference] The choice of candidate key depends on which business rule is considered the primary constraint. If we select the composite of all four as the primary key, then the other two become alternate keys.

**Normalization Analysis:**

Using `(StudentID, AdvisorID, MeetingDate, MeetingTime)` as the candidate key:

- **1NF**: ✓ Yes - atomic attributes
- **2NF**: ✗ No - partial dependencies:
  - StudentMajor depends on only StudentID
  - AdvisorDepartment, AdvisorOffice depend on only AdvisorID
- **3NF**: ✗ No - fails 2NF
- **BCNF**: ✗ No - fails 3NF

---

## Exercise 7: Vehicle Rental Service

**Relation:**
```
RENTAL(VehicleID, VehicleMake, VehicleModel, VehicleYear, CustomerID, 
       CustomerName, CustomerLicense, RentalStartDate, RentalEndDate, 
       DailyRate, TotalCost, InsuranceType)
```

**Business Rules:**
1. Each vehicle has a unique VehicleID with one make, model, and year
2. Each customer has a unique CustomerID, one name, and one driver's license number
3. A vehicle can be rented by only one customer at a time
4. A customer can rent multiple vehicles simultaneously
5. The daily rate is determined by the vehicle make and model combination
6. TotalCost = DailyRate × (RentalEndDate - RentalStartDate + 1)
7. Insurance type is chosen per rental (not per customer or vehicle)
8. This relation records only currently active rentals

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 7

**Functional Dependencies:**

1. `VehicleID → VehicleMake, VehicleModel, VehicleYear` (and transitively → DailyRate)
2. `VehicleMake, VehicleModel → DailyRate`
3. `CustomerID → CustomerName, CustomerLicense`
4. `VehicleID → CustomerID, RentalStartDate, RentalEndDate, InsuranceType` (and transitively → CustomerName, CustomerLicense, TotalCost)
5. `VehicleID → TotalCost` (transitively through DailyRate and RentalEndDate - RentalStartDate)

[Inference] The FD `VehicleMake, VehicleModel → DailyRate` assumes that daily rates are standardized by make/model combination, not individually priced per vehicle.

**Principles Used in Identification:**

- **Single determinant for active rentals**: VehicleID alone determines all attributes since only current rentals are recorded
- **Multi-attribute determinant**: DailyRate requires both VehicleMake AND VehicleModel
- **Computed attributes**: TotalCost is functionally dependent on DailyRate and the date range
- **Transitive dependency layers**: VehicleID → VehicleMake, VehicleModel → DailyRate (two-step transitive)

**Candidate Key:**
- `VehicleID` (single attribute, since each vehicle has only one active rental)

**Normalization Analysis:**

- **1NF**: ✓ Yes - all atomic values
- **2NF**: ✓ Yes - no partial dependencies possible with single-attribute key
- **3NF**: ✗ No - transitive dependencies exist:
  - VehicleID → CustomerID → CustomerName, CustomerLicense
  - VehicleID → VehicleMake, VehicleModel → DailyRate
- **BCNF**: ✗ No - `VehicleMake, VehicleModel → DailyRate` violates BCNF because (VehicleMake, VehicleModel) is not a superkey

---

## Exercise 8: Conference Paper Submissions

**Relation:**
```
SUBMISSION(PaperID, Title, AuthorID, AuthorName, AuthorEmail, 
           ReviewerID, ReviewerName, ReviewScore, TrackID, TrackName, 
           SubmissionDate, AuthorAffiliation)
```

**Business Rules:**
1. Each paper has a unique PaperID, one title, and one submission date
2. A paper is submitted to exactly one conference track
3. Each track has a unique TrackID and one track name
4. A paper can have multiple authors (listed with separate records)
5. Each author has a unique AuthorID, one name, one email, and one affiliation
6. Each paper is reviewed by multiple reviewers
7. Each reviewer has a unique ReviewerID and one name
8. Each reviewer gives one score per paper
9. A reviewer can review multiple papers

**Your Task:** Identify all functional dependencies

---

## Solution to Exercise 8

**Functional Dependencies:**

1. `PaperID → Title, TrackID, SubmissionDate` (and transitively → TrackName)
2. `TrackID → TrackName`
3. `AuthorID → AuthorName, AuthorEmail, AuthorAffiliation`
4. `ReviewerID → ReviewerName`
5. `PaperID, ReviewerID → ReviewScore`
6. `PaperID, AuthorID → ∅` (no non-key attributes determined by this combination alone)

[Inference] The relation contains a complex structure with two many-to-many relationships: papers-to-authors and papers-to-reviewers. This creates ambiguity about the true candidate key.

**Principles Used in Identification:**

- **Multiple many-to-many relationships**: Both authorship and reviewing create composite keys
- **Empty determination**: Some attribute combinations determine no non-key attributes
- **Separate determinant paths**: PaperID + ReviewerID determines ReviewScore, but PaperID + AuthorID determines nothing unique
- **Design issue recognition**: This relation conflates two separate many-to-many relationships

**Candidate Key:**
- `(PaperID, AuthorID, ReviewerID)` is technically the candidate key to uniquely identify each row

[Inference] This design has significant issues because it creates unnecessary data redundancy. Each paper-author-reviewer combination must exist, even though ReviewScore doesn't depend on AuthorID.

**Normalization Analysis:**

- **1NF**: ✓ Yes - atomic attributes
- **2NF**: ✗ No - partial dependencies:
  - Title, TrackID, SubmissionDate depend on only PaperID
  - AuthorName, AuthorEmail, AuthorAffiliation depend on only AuthorID
  - ReviewerName depends on only ReviewerID
  - ReviewScore depends on only PaperID and ReviewerID (not on AuthorID)
- **3NF**: ✗ No - fails 2NF, plus transitive dependency (PaperID → TrackID → TrackName)
- **BCNF**: ✗ No - fails 3NF

**Design Note:** [Inference] This relation should be decomposed into at least three separate relations: PAPERS, AUTHORSHIP, and REVIEWS to properly model the business rules without redundancy.

---

# Exercise Type 1: Decomposition Exercise

## Exercise: Online Bookstore Order System

**Original Relation (in 1NF):**
```
ORDER_LINE(OrderID, OrderDate, CustomerID, CustomerName, CustomerEmail, 
           BookISBN, BookTitle, AuthorID, AuthorName, PublisherName, 
           Quantity, UnitPrice, CustomerCity)
```

**Sample Data:**
```
| OrderID | OrderDate  | CustomerID | CustomerName | CustomerEmail      | BookISBN      | BookTitle        | AuthorID | AuthorName      | PublisherName | Quantity | UnitPrice | CustomerCity |
|---------|------------|------------|--------------|-------------------|---------------|------------------|----------|-----------------|---------------|----------|-----------|--------------|
| O001    | 2024-01-15 | C101       | John Smith   | john@email.com    | 978-0134685991| Effective Java   | A201     | Joshua Bloch    | Addison-Wesley| 2        | 45.00     | Boston       |
| O001    | 2024-01-15 | C101       | John Smith   | john@email.com    | 978-0596009205| Head First Java  | A202     | Kathy Sierra    | O'Reilly      | 1        | 39.99     | Boston       |
| O002    | 2024-01-16 | C102       | Jane Doe     | jane@email.com    | 978-0134685991| Effective Java   | A201     | Joshua Bloch    | Addison-Wesley| 1        | 45.00     | Chicago      |
```

**Business Rules:**
1. Each order has a unique OrderID and occurs on one date
2. Each order is placed by exactly one customer
3. Each customer has a unique CustomerID with one name, email, and city
4. An order can contain multiple books (different BookISBN values)
5. Each book has a unique ISBN with one title and one publisher name
6. Each book is written by exactly one primary author
7. Each author has a unique AuthorID and one name
8. Quantity represents how many copies of that book were ordered in that specific order
9. UnitPrice is the price per book at the time of the order

**Given Functional Dependencies:**
```
FD1:  OrderID → OrderDate, CustomerID
FD2:  CustomerID → CustomerName, CustomerEmail, CustomerCity
FD3:  BookISBN → BookTitle, AuthorID, PublisherName
FD4:  AuthorID → AuthorName
FD5:  OrderID, BookISBN → Quantity, UnitPrice
```

**Candidate Key:**
- `(OrderID, BookISBN)`

**Your Tasks:**

1. **Verify the relation is in 1NF**
2. **Decompose to 2NF** - Eliminate all partial dependencies
3. **Decompose to 3NF** - Eliminate all transitive dependencies
4. **Decompose to BCNF** - Ensure all determinants are candidate keys
5. **For each decomposition step:**
   - List the resulting relations with their attributes
   - Identify the primary key for each relation
   - State which dependencies are preserved in each relation
   - Verify lossless join property
   - Verify dependency preservation

---

# Solution: Step-by-Step Decomposition

## Step 1: Verify 1NF

**Analysis:**
- All attributes contain atomic (single) values ✓
- No repeating groups ✓
- Each row is unique (identified by OrderID + BookISBN) ✓

**Conclusion:** The relation is in 1NF.

---

## Step 2: Decompose to 2NF

**Goal:** Eliminate partial dependencies (non-prime attributes dependent on part of the candidate key)

**Candidate Key:** `(OrderID, BookISBN)`

**Prime Attributes:** OrderID, BookISBN

**Non-Prime Attributes:** OrderDate, CustomerID, CustomerName, CustomerEmail, BookTitle, AuthorID, AuthorName, PublisherName, Quantity, UnitPrice, CustomerCity

**Partial Dependencies Identified:**

- `OrderID → OrderDate, CustomerID` (FD1) - **PARTIAL DEPENDENCY**
  - Depends on only OrderID, not the full key
  
- `BookISBN → BookTitle, AuthorID, PublisherName` (FD3) - **PARTIAL DEPENDENCY**
  - Depends on only BookISBN, not the full key

- `CustomerID → CustomerName, CustomerEmail, CustomerCity` (FD2) - **TRANSITIVE through OrderID**
  - First: OrderID → CustomerID (partial)
  - Then: CustomerID → CustomerName, CustomerEmail, CustomerCity
  
- `AuthorID → AuthorName` (FD4) - **TRANSITIVE through BookISBN**
  - First: BookISBN → AuthorID (partial)
  - Then: AuthorID → AuthorName

- `OrderID, BookISBN → Quantity, UnitPrice` (FD5) - **NOT PARTIAL**
  - Depends on the full candidate key ✓

**Decomposition to 2NF:**

**R1: ORDER_LINE_2NF** (intersection entity - keeps full key dependencies)
```
ORDER_LINE_2NF(OrderID, BookISBN, Quantity, UnitPrice)
Primary Key: (OrderID, BookISBN)
FDs preserved: OrderID, BookISBN → Quantity, UnitPrice
```

**R2: ORDERS_2NF**
```
ORDERS_2NF(OrderID, OrderDate, CustomerID)
Primary Key: OrderID
FDs preserved: OrderID → OrderDate, CustomerID
```

**R3: BOOKS_2NF**
```
BOOKS_2NF(BookISBN, BookTitle, AuthorID, PublisherName)
Primary Key: BookISBN
FDs preserved: BookISBN → BookTitle, AuthorID, PublisherName
```

**R4: CUSTOMERS_2NF**
```
CUSTOMERS_2NF(CustomerID, CustomerName, CustomerEmail, CustomerCity)
Primary Key: CustomerID
FDs preserved: CustomerID → CustomerName, CustomerEmail, CustomerCity
```

**R5: AUTHORS_2NF**
```
AUTHORS_2NF(AuthorID, AuthorName)
Primary Key: AuthorID
FDs preserved: AuthorID → AuthorName
```

**Verification:**

**Lossless Join:**
- Can reconstruct original relation by joining:
  - ORDER_LINE_2NF ⋈ ORDERS_2NF (on OrderID)
  - ⋈ BOOKS_2NF (on BookISBN)
  - ⋈ CUSTOMERS_2NF (on CustomerID)
  - ⋈ AUTHORS_2NF (on AuthorID)
- Each join uses a foreign key that references a primary key ✓

**Dependency Preservation:**
- FD1: Preserved in ORDERS_2NF ✓
- FD2: Preserved in CUSTOMERS_2NF ✓
- FD3: Preserved in BOOKS_2NF ✓
- FD4: Preserved in AUTHORS_2NF ✓
- FD5: Preserved in ORDER_LINE_2NF ✓
- All original FDs are preserved ✓

**2NF Check for Each Relation:**
- R1: Candidate key is (OrderID, BookISBN), all non-key attributes depend on full key ✓
- R2: Candidate key is OrderID (single attribute), no partial dependencies possible ✓
- R3: Candidate key is BookISBN (single attribute), no partial dependencies possible ✓
- R4: Candidate key is CustomerID (single attribute), no partial dependencies possible ✓
- R5: Candidate key is AuthorID (single attribute), no partial dependencies possible ✓

**Conclusion:** All relations are now in 2NF.

---

## Step 3: Decompose to 3NF

**Goal:** Eliminate transitive dependencies (non-prime attribute → non-prime attribute)

**Analysis of Each 2NF Relation:**

**R1: ORDER_LINE_2NF(OrderID, BookISBN, Quantity, UnitPrice)**
- Candidate Key: (OrderID, BookISBN)
- All attributes are either part of the key or directly dependent on the full key
- No transitive dependencies ✓
- **Already in 3NF**

**R2: ORDERS_2NF(OrderID, OrderDate, CustomerID)**
- Candidate Key: OrderID
- FD: OrderID → OrderDate, CustomerID
- CustomerID is a non-prime attribute that references another entity
- However, OrderDate and CustomerID both depend directly on OrderID, not on each other
- No transitive dependency here (CustomerID is not functionally determined by another non-prime attribute)
- **Already in 3NF**

**R3: BOOKS_2NF(BookISBN, BookTitle, AuthorID, PublisherName)**
- Candidate Key: BookISBN
- FDs within this relation:
  - BookISBN → BookTitle, AuthorID, PublisherName (direct)
  - AuthorID → AuthorName (but AuthorName is not in this relation anymore)
- AuthorID is a non-prime attribute
- No transitive dependencies within this relation ✓
- **Already in 3NF**

**R4: CUSTOMERS_2NF(CustomerID, CustomerName, CustomerEmail, CustomerCity)**
- Candidate Key: CustomerID
- FD: CustomerID → CustomerName, CustomerEmail, CustomerCity
- All non-key attributes depend directly on CustomerID
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R5: AUTHORS_2NF(AuthorID, AuthorName)**
- Candidate Key: AuthorID
- FD: AuthorID → AuthorName
- Only one non-key attribute
- No transitive dependencies possible ✓
- **Already in 3NF**

**3NF Relations (Same as 2NF):**

```
ORDER_LINE_3NF(OrderID, BookISBN, Quantity, UnitPrice)
Primary Key: (OrderID, BookISBN)

ORDERS_3NF(OrderID, OrderDate, CustomerID)
Primary Key: OrderID

BOOKS_3NF(BookISBN, BookTitle, AuthorID, PublisherName)
Primary Key: BookISBN

CUSTOMERS_3NF(CustomerID, CustomerName, CustomerEmail, CustomerCity)
Primary Key: CustomerID

AUTHORS_3NF(AuthorID, AuthorName)
Primary Key: AuthorID
```

**Verification:**

**Lossless Join:** Same as 2NF verification ✓

**Dependency Preservation:** All FDs still preserved ✓

**3NF Check:**
- No non-prime attribute transitively depends on any candidate key ✓
- For each FD X → A: either
  - X is a superkey, OR
  - A is a prime attribute (part of some candidate key)
- All relations satisfy 3NF conditions ✓

**Conclusion:** All relations are in 3NF. The 2NF decomposition already eliminated transitive dependencies because we separated the entities properly.

---

## Step 4: Decompose to BCNF

**Goal:** Ensure every determinant is a candidate key

**BCNF Requirement:** For every non-trivial FD X → Y, X must be a superkey.

**Analysis of Each 3NF Relation:**

**R1: ORDER_LINE_3NF(OrderID, BookISBN, Quantity, UnitPrice)**
- Candidate Key: (OrderID, BookISBN)
- FD: OrderID, BookISBN → Quantity, UnitPrice
- Determinant (OrderID, BookISBN) is a candidate key ✓
- **In BCNF**

**R2: ORDERS_3NF(OrderID, OrderDate, CustomerID)**
- Candidate Key: OrderID
- FD: OrderID → OrderDate, CustomerID
- Determinant (OrderID) is a candidate key ✓
- **In BCNF**

**R3: BOOKS_3NF(BookISBN, BookTitle, AuthorID, PublisherName)**
- Candidate Key: BookISBN
- FD: BookISBN → BookTitle, AuthorID, PublisherName
- Determinant (BookISBN) is a candidate key ✓
- **In BCNF**

**R4: CUSTOMERS_3NF(CustomerID, CustomerName, CustomerEmail, CustomerCity)**
- Candidate Key: CustomerID
- FDs within this relation:
  - CustomerID → CustomerName, CustomerEmail, CustomerCity
- Determinant (CustomerID) is a candidate key ✓

[Inference] If there was a business rule that CustomerEmail must be unique and could determine CustomerID (CustomerEmail → CustomerID), then we would have a BCNF violation. However, based on the given FDs, no such dependency exists.

- **In BCNF**

**R5: AUTHORS_3NF(AuthorID, AuthorName)**
- Candidate Key: AuthorID
- FD: AuthorID → AuthorName
- Determinant (AuthorID) is a candidate key ✓
- **In BCNF**

**BCNF Relations (Same as 3NF):**

```
ORDER_LINE_BCNF(OrderID, BookISBN, Quantity, UnitPrice)
Primary Key: (OrderID, BookISBN)
Foreign Keys: OrderID references ORDERS_BCNF, BookISBN references BOOKS_BCNF

ORDERS_BCNF(OrderID, OrderDate, CustomerID)
Primary Key: OrderID
Foreign Key: CustomerID references CUSTOMERS_BCNF

BOOKS_BCNF(BookISBN, BookTitle, AuthorID, PublisherName)
Primary Key: BookISBN
Foreign Key: AuthorID references AUTHORS_BCNF

CUSTOMERS_BCNF(CustomerID, CustomerName, CustomerEmail, CustomerCity)
Primary Key: CustomerID

AUTHORS_BCNF(AuthorID, AuthorName)
Primary Key: AuthorID
```

**Verification:**

**Lossless Join:** 
- Original relation can be reconstructed by natural joins ✓
- Join path: ORDER_LINE_BCNF ⋈ ORDERS_BCNF ⋈ CUSTOMERS_BCNF ⋈ BOOKS_BCNF ⋈ AUTHORS_BCNF

**Dependency Preservation:**
- All original FDs are preserved across the relations ✓

**BCNF Check:**
- Every determinant in every FD is a candidate key ✓

**Conclusion:** All relations are in BCNF.

---

## Summary of Decomposition

**Original Relation:**
- 1 relation with 13 attributes
- Candidate key: (OrderID, BookISBN)
- Multiple partial and transitive dependencies

**Final BCNF Schema:**
- 5 relations
- No partial dependencies
- No transitive dependencies
- All determinants are candidate keys
- Lossless join preserved
- All dependencies preserved

**Key Transformations:**

1. **1NF → 2NF:** Separated partial dependencies by creating separate relations for ORDERS, BOOKS, CUSTOMERS, and AUTHORS
2. **2NF → 3NF:** No additional decomposition needed (proper entity separation already eliminated transitive dependencies)
3. **3NF → BCNF:** No additional decomposition needed (all determinants were already candidate keys)

**Benefits of Normalization:**

1. **Eliminated Update Anomalies:** Customer name change only updates CUSTOMERS_BCNF (one place)
2. **Eliminated Insertion Anomalies:** Can add a customer without requiring an order
3. **Eliminated Deletion Anomalies:** Deleting last order doesn't lose customer information
4. **Reduced Redundancy:** Author name stored once per author, not once per book per order
5. **Improved Data Integrity:** Referential integrity enforced through foreign keys

**Storage Comparison:**

Original (denormalized):
- 3 rows × 13 attributes = 39 attribute values (with massive redundancy)

Normalized (BCNF):
- ORDER_LINE_BCNF: 3 rows × 4 attributes = 12 values
- ORDERS_BCNF: 2 rows × 3 attributes = 6 values
- BOOKS_BCNF: 2 rows × 4 attributes = 8 values
- CUSTOMERS_BCNF: 2 rows × 4 attributes = 8 values
- AUTHORS_BCNF: 2 rows × 2 attributes = 4 values
- **Total: 38 attribute values** (with no redundancy)

[Inference] The normalized schema stores approximately the same amount of data but with zero redundancy, making updates safer and more efficient.

---

# Exercise Type 1: Decomposition Exercise

## Exercise: Hospital Patient Treatment System

**Original Relation (in 1NF):**
```
TREATMENT(PatientID, PatientName, PatientDOB, DoctorID, DoctorName, 
          DoctorSpecialty, ClinicID, ClinicName, ClinicCity, 
          TreatmentDate, DiagnosisCode, DiagnosisDescription, 
          MedicationID, MedicationName, Dosage, DoctorPhone)
```

**Sample Data:**
```
| PatientID | PatientName  | PatientDOB | DoctorID | DoctorName   | DoctorSpecialty | ClinicID | ClinicName      | ClinicCity | TreatmentDate | DiagnosisCode | DiagnosisDescription | MedicationID | MedicationName | Dosage | DoctorPhone  |
|-----------|--------------|------------|----------|--------------|-----------------|----------|-----------------|------------|---------------|---------------|---------------------|--------------|----------------|--------|--------------|
| P001      | Alice Brown  | 1985-03-15 | D101     | Dr. Smith    | Cardiology      | C201     | Heart Center    | Boston     | 2024-02-10    | I50.9         | Heart Failure       | M301         | Lisinopril     | 10mg   | 555-0101     |
| P001      | Alice Brown  | 1985-03-15 | D101     | Dr. Smith    | Cardiology      | C201     | Heart Center    | Boston     | 2024-02-10    | I50.9         | Heart Failure       | M302         | Metoprolol     | 25mg   | 555-0101     |
| P001      | Alice Brown  | 1985-03-15 | D102     | Dr. Johnson  | Internal Med    | C202     | City Hospital   | Boston     | 2024-03-05    | E11.9         | Type 2 Diabetes     | M303         | Metformin      | 500mg  | 555-0102     |
| P002      | Bob Wilson   | 1990-07-22 | D101     | Dr. Smith    | Cardiology      | C201     | Heart Center    | Boston     | 2024-02-15    | I10           | Hypertension        | M301         | Lisinopril     | 20mg   | 555-0101     |
```

**Business Rules:**
1. Each patient has a unique PatientID with one name and date of birth
2. Each doctor has a unique DoctorID with one name, one specialty, and one phone number
3. Each clinic has a unique ClinicID with one name and is located in one city
4. A doctor works at multiple clinics, and a clinic has multiple doctors
5. Each diagnosis code (e.g., I50.9) has exactly one standard description
6. Each medication has a unique MedicationID and one medication name
7. A patient visits a doctor at a specific clinic on a specific date (one treatment visit)
8. During one treatment visit, a patient receives exactly one diagnosis
9. A single treatment visit can prescribe multiple medications
10. The dosage is specific to each medication prescribed during that treatment visit
11. A doctor can treat patients at different clinics on different dates

**Given Functional Dependencies:**
```
FD1:  PatientID → PatientName, PatientDOB
FD2:  DoctorID → DoctorName, DoctorSpecialty, DoctorPhone
FD3:  ClinicID → ClinicName, ClinicCity
FD4:  DiagnosisCode → DiagnosisDescription
FD5:  MedicationID → MedicationName
FD6:  PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode
FD7:  PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID → Dosage
```

**Candidate Key:**
- `(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)`

**Your Tasks:**

1. **Verify the relation is in 1NF**
2. **Decompose to 2NF** - Eliminate all partial dependencies
3. **Decompose to 3NF** - Eliminate all transitive dependencies
4. **Decompose to BCNF** - Ensure all determinants are candidate keys
5. **For each decomposition step:**
   - List the resulting relations with their attributes
   - Identify the primary key for each relation
   - State which dependencies are preserved in each relation
   - Verify lossless join property
   - Verify dependency preservation

---

# Solution: Step-by-Step Decomposition

## Step 1: Verify 1NF

**Analysis:**
- All attributes contain atomic (single) values ✓
- No repeating groups ✓
- Each row is unique (identified by PatientID + DoctorID + ClinicID + TreatmentDate + MedicationID) ✓

**Conclusion:** The relation is in 1NF.

---

## Step 2: Decompose to 2NF

**Goal:** Eliminate partial dependencies (non-prime attributes dependent on part of the candidate key)

**Candidate Key:** `(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)`

**Prime Attributes:** PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID

**Non-Prime Attributes:** PatientName, PatientDOB, DoctorName, DoctorSpecialty, ClinicName, ClinicCity, DiagnosisCode, DiagnosisDescription, MedicationName, Dosage, DoctorPhone

**Partial Dependencies Identified:**

- `PatientID → PatientName, PatientDOB` (FD1) - **PARTIAL DEPENDENCY**
  - Depends on only PatientID (part of the key)

- `DoctorID → DoctorName, DoctorSpecialty, DoctorPhone` (FD2) - **PARTIAL DEPENDENCY**
  - Depends on only DoctorID (part of the key)

- `ClinicID → ClinicName, ClinicCity` (FD3) - **PARTIAL DEPENDENCY**
  - Depends on only ClinicID (part of the key)

- `DiagnosisCode → DiagnosisDescription` (FD4) - **TRANSITIVE (also involves partial)**
  - First: PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode
  - Then: DiagnosisCode → DiagnosisDescription

- `MedicationID → MedicationName` (FD5) - **PARTIAL DEPENDENCY**
  - Depends on only MedicationID (part of the key)

- `PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode` (FD6) - **PARTIAL DEPENDENCY**
  - Depends on part of the key (not including MedicationID)

- `PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID → Dosage` (FD7) - **NOT PARTIAL**
  - Depends on the full candidate key ✓

**Decomposition to 2NF:**

**R1: PRESCRIPTION_2NF** (intersection entity - keeps full key dependencies)
```
PRESCRIPTION_2NF(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID, Dosage)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)
FDs preserved: PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID → Dosage
```

**R2: TREATMENT_VISIT_2NF**
```
TREATMENT_VISIT_2NF(PatientID, DoctorID, ClinicID, TreatmentDate, DiagnosisCode)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate)
FDs preserved: PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode
```

**R3: PATIENTS_2NF**
```
PATIENTS_2NF(PatientID, PatientName, PatientDOB)
Primary Key: PatientID
FDs preserved: PatientID → PatientName, PatientDOB
```

**R4: DOCTORS_2NF**
```
DOCTORS_2NF(DoctorID, DoctorName, DoctorSpecialty, DoctorPhone)
Primary Key: DoctorID
FDs preserved: DoctorID → DoctorName, DoctorSpecialty, DoctorPhone
```

**R5: CLINICS_2NF**
```
CLINICS_2NF(ClinicID, ClinicName, ClinicCity)
Primary Key: ClinicID
FDs preserved: ClinicID → ClinicName, ClinicCity
```

**R6: MEDICATIONS_2NF**
```
MEDICATIONS_2NF(MedicationID, MedicationName)
Primary Key: MedicationID
FDs preserved: MedicationID → MedicationName
```

**R7: DIAGNOSES_2NF**
```
DIAGNOSES_2NF(DiagnosisCode, DiagnosisDescription)
Primary Key: DiagnosisCode
FDs preserved: DiagnosisCode → DiagnosisDescription
```

**Verification:**

**Lossless Join:**
- Can reconstruct original relation by joining:
  - PRESCRIPTION_2NF ⋈ TREATMENT_VISIT_2NF (on PatientID, DoctorID, ClinicID, TreatmentDate)
  - ⋈ PATIENTS_2NF (on PatientID)
  - ⋈ DOCTORS_2NF (on DoctorID)
  - ⋈ CLINICS_2NF (on ClinicID)
  - ⋈ MEDICATIONS_2NF (on MedicationID)
  - ⋈ DIAGNOSES_2NF (on DiagnosisCode)
- Each join uses foreign keys that reference primary keys ✓

**Dependency Preservation:**
- FD1: Preserved in PATIENTS_2NF ✓
- FD2: Preserved in DOCTORS_2NF ✓
- FD3: Preserved in CLINICS_2NF ✓
- FD4: Preserved in DIAGNOSES_2NF ✓
- FD5: Preserved in MEDICATIONS_2NF ✓
- FD6: Preserved in TREATMENT_VISIT_2NF ✓
- FD7: Preserved in PRESCRIPTION_2NF ✓
- All original FDs are preserved ✓

**2NF Check for Each Relation:**
- R1: Key is (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID), Dosage depends on full key ✓
- R2: Key is (PatientID, DoctorID, ClinicID, TreatmentDate), DiagnosisCode depends on full key ✓
- R3: Single-attribute key (PatientID), no partial dependencies possible ✓
- R4: Single-attribute key (DoctorID), no partial dependencies possible ✓
- R5: Single-attribute key (ClinicID), no partial dependencies possible ✓
- R6: Single-attribute key (MedicationID), no partial dependencies possible ✓
- R7: Single-attribute key (DiagnosisCode), no partial dependencies possible ✓

**Conclusion:** All relations are now in 2NF.

---

## Step 3: Decompose to 3NF

**Goal:** Eliminate transitive dependencies (non-prime attribute → non-prime attribute)

**Analysis of Each 2NF Relation:**

**R1: PRESCRIPTION_2NF(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID, Dosage)**
- Candidate Key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)
- All attributes are either part of the key or directly dependent on the full key
- No transitive dependencies ✓
- **Already in 3NF**

**R2: TREATMENT_VISIT_2NF(PatientID, DoctorID, ClinicID, TreatmentDate, DiagnosisCode)**
- Candidate Key: (PatientID, DoctorID, ClinicID, TreatmentDate)
- FD: PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode
- DiagnosisCode depends directly on the key
- However, we know from FD4 that DiagnosisCode → DiagnosisDescription
- But DiagnosisDescription is not in this relation (it's in DIAGNOSES_2NF)
- No transitive dependencies within this relation ✓
- **Already in 3NF**

**R3: PATIENTS_2NF(PatientID, PatientName, PatientDOB)**
- Candidate Key: PatientID
- FD: PatientID → PatientName, PatientDOB
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R4: DOCTORS_2NF(DoctorID, DoctorName, DoctorSpecialty, DoctorPhone)**
- Candidate Key: DoctorID
- FD: DoctorID → DoctorName, DoctorSpecialty, DoctorPhone
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R5: CLINICS_2NF(ClinicID, ClinicName, ClinicCity)**
- Candidate Key: ClinicID
- FD: ClinicID → ClinicName, ClinicCity
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R6: MEDICATIONS_2NF(MedicationID, MedicationName)**
- Candidate Key: MedicationID
- FD: MedicationID → MedicationName
- Only one non-key attribute
- No transitive dependencies possible ✓
- **Already in 3NF**

**R7: DIAGNOSES_2NF(DiagnosisCode, DiagnosisDescription)**
- Candidate Key: DiagnosisCode
- FD: DiagnosisCode → DiagnosisDescription
- Only one non-key attribute
- No transitive dependencies possible ✓
- **Already in 3NF**

**3NF Relations (Same as 2NF):**

```
PRESCRIPTION_3NF(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID, Dosage)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)

TREATMENT_VISIT_3NF(PatientID, DoctorID, ClinicID, TreatmentDate, DiagnosisCode)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate)

PATIENTS_3NF(PatientID, PatientName, PatientDOB)
Primary Key: PatientID

DOCTORS_3NF(DoctorID, DoctorName, DoctorSpecialty, DoctorPhone)
Primary Key: DoctorID

CLINICS_3NF(ClinicID, ClinicName, ClinicCity)
Primary Key: ClinicID

MEDICATIONS_3NF(MedicationID, MedicationName)
Primary Key: MedicationID

DIAGNOSES_3NF(DiagnosisCode, DiagnosisDescription)
Primary Key: DiagnosisCode
```

**Verification:**

**Lossless Join:** Same as 2NF verification ✓

**Dependency Preservation:** All FDs still preserved ✓

**3NF Check:**
- No non-prime attribute transitively depends on any candidate key ✓
- For each FD X → A: either X is a superkey, OR A is a prime attribute ✓
- All relations satisfy 3NF conditions ✓

**Conclusion:** All relations are in 3NF. The 2NF decomposition already eliminated transitive dependencies through proper entity separation.

---

## Step 4: Decompose to BCNF

**Goal:** Ensure every determinant is a candidate key

**BCNF Requirement:** For every non-trivial FD X → Y, X must be a superkey.

**Analysis of Each 3NF Relation:**

**R1: PRESCRIPTION_3NF(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID, Dosage)**
- Candidate Key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)
- FD: PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID → Dosage
- Determinant is a candidate key ✓
- **In BCNF**

**R2: TREATMENT_VISIT_3NF(PatientID, DoctorID, ClinicID, TreatmentDate, DiagnosisCode)**
- Candidate Key: (PatientID, DoctorID, ClinicID, TreatmentDate)
- FD: PatientID, DoctorID, ClinicID, TreatmentDate → DiagnosisCode
- Determinant is a candidate key ✓
- **In BCNF**

**R3: PATIENTS_3NF(PatientID, PatientName, PatientDOB)**
- Candidate Key: PatientID
- FD: PatientID → PatientName, PatientDOB
- Determinant is a candidate key ✓
- **In BCNF**

**R4: DOCTORS_3NF(DoctorID, DoctorName, DoctorSpecialty, DoctorPhone)**
- Candidate Key: DoctorID
- FD: DoctorID → DoctorName, DoctorSpecialty, DoctorPhone
- Determinant is a candidate key ✓
- **In BCNF**

**R5: CLINICS_3NF(ClinicID, ClinicName, ClinicCity)**
- Candidate Key: ClinicID
- FD: ClinicID → ClinicName, ClinicCity
- Determinant is a candidate key ✓
- **In BCNF**

**R6: MEDICATIONS_3NF(MedicationID, MedicationName)**
- Candidate Key: MedicationID
- FD: MedicationID → MedicationName
- Determinant is a candidate key ✓
- **In BCNF**

**R7: DIAGNOSES_3NF(DiagnosisCode, DiagnosisDescription)**
- Candidate Key: DiagnosisCode
- FD: DiagnosisCode → DiagnosisDescription
- Determinant is a candidate key ✓
- **In BCNF**

**BCNF Relations (Same as 3NF):**

```
PRESCRIPTION_BCNF(PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID, Dosage)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID)
Foreign Keys: 
  - PatientID references PATIENTS_BCNF
  - DoctorID references DOCTORS_BCNF
  - ClinicID references CLINICS_BCNF
  - MedicationID references MEDICATIONS_BCNF
  - (PatientID, DoctorID, ClinicID, TreatmentDate) references TREATMENT_VISIT_BCNF

TREATMENT_VISIT_BCNF(PatientID, DoctorID, ClinicID, TreatmentDate, DiagnosisCode)
Primary Key: (PatientID, DoctorID, ClinicID, TreatmentDate)
Foreign Keys:
  - PatientID references PATIENTS_BCNF
  - DoctorID references DOCTORS_BCNF
  - ClinicID references CLINICS_BCNF
  - DiagnosisCode references DIAGNOSES_BCNF

PATIENTS_BCNF(PatientID, PatientName, PatientDOB)
Primary Key: PatientID

DOCTORS_BCNF(DoctorID, DoctorName, DoctorSpecialty, DoctorPhone)
Primary Key: DoctorID

CLINICS_BCNF(ClinicID, ClinicName, ClinicCity)
Primary Key: ClinicID

MEDICATIONS_BCNF(MedicationID, MedicationName)
Primary Key: MedicationID

DIAGNOSES_BCNF(DiagnosisCode, DiagnosisDescription)
Primary Key: DiagnosisCode
```

**Verification:**

**Lossless Join:**
- Original relation can be reconstructed by natural joins ✓
- Join path: PRESCRIPTION_BCNF ⋈ TREATMENT_VISIT_BCNF ⋈ PATIENTS_BCNF ⋈ DOCTORS_BCNF ⋈ CLINICS_BCNF ⋈ MEDICATIONS_BCNF ⋈ DIAGNOSES_BCNF

**Dependency Preservation:**
- All original FDs are preserved across the relations ✓

**BCNF Check:**
- Every determinant in every FD is a candidate key ✓

**Conclusion:** All relations are in BCNF.

---

## Summary of Decomposition

**Original Relation:**
- 1 relation with 16 attributes
- Candidate key: (PatientID, DoctorID, ClinicID, TreatmentDate, MedicationID) - 5 attributes
- Multiple partial and transitive dependencies

**Final BCNF Schema:**
- 7 relations
- No partial dependencies
- No transitive dependencies
- All determinants are candidate keys
- Lossless join preserved
- All dependencies preserved

**Key Transformations:**

1. **1NF → 2NF:** Separated partial dependencies by creating relations for PATIENTS, DOCTORS, CLINICS, MEDICATIONS, DIAGNOSES, TREATMENT_VISIT, and PRESCRIPTION
2. **2NF → 3NF:** No additional decomposition needed (proper entity separation already eliminated transitive dependencies)
3. **3NF → BCNF:** No additional decomposition needed (all determinants were already candidate keys)

**Benefits of Normalization:**

1. **Eliminated Update Anomalies:**
   - Changing a doctor's phone number: Update only DOCTORS_BCNF (one place)
   - Updating diagnosis description: Update only DIAGNOSES_BCNF (one place)
   - Changing medication name: Update only MEDICATIONS_BCNF (one place)

2. **Eliminated Insertion Anomalies:**
   - Can add a new patient without requiring a treatment
   - Can add a new medication without prescribing it
   - Can add a new diagnosis code without having a patient with that diagnosis

3. **Eliminated Deletion Anomalies:**
   - Deleting all prescriptions for a medication doesn't lose the medication information
   - Deleting a patient's last treatment doesn't lose patient demographic data
   - Deleting all treatments with a diagnosis doesn't lose the diagnosis code definition

4. **Reduced Redundancy:**
   - Doctor information stored once, not repeated for every treatment
   - Diagnosis descriptions stored once per code, not per treatment
   - Clinic information stored once, not per treatment

5. **Improved Data Integrity:**
   - Referential integrity enforced through foreign keys
   - Standard diagnosis descriptions maintained centrally
   - Consistent medication names across all prescriptions

**Storage Comparison:**

Original (denormalized):
- 4 rows × 16 attributes = 64 attribute values (with massive redundancy)

Normalized (BCNF):
- PRESCRIPTION_BCNF: 4 rows × 6 attributes = 24 values
- TREATMENT_VISIT_BCNF: 3 rows × 5 attributes = 15 values
- PATIENTS_BCNF: 2 rows × 3 attributes = 6 values
- DOCTORS_BCNF: 2 rows × 4 attributes = 8 values
- CLINICS_BCNF: 2 rows × 3 attributes = 6 values
- MEDICATIONS_BCNF: 4 rows × 2 attributes = 8 values
- DIAGNOSES_BCNF: 3 rows × 2 attributes = 6 values
- **Total: 73 attribute values** (with minimal redundancy)

[Inference] While the normalized schema appears to have more total values, this is because we've eliminated redundancy by storing lookup data (medications, diagnoses) only once. In a larger dataset, the savings would be substantial as doctor names, clinic names, and diagnosis descriptions wouldn't be repeated thousands of times.

**Real-World Implications:**

- **Scalability:** With thousands of treatments, normalized schema saves significant storage
- **Maintainability:** Updating standard diagnosis descriptions is centralized
- **Data Quality:** Prevents inconsistent spellings of medication names or doctor names
- **Regulatory Compliance:** Easier to audit and ensure data consistency for healthcare regulations

---

# Exercise Type 1: Decomposition Exercise

## Exercise: University Course Scheduling System

**Original Relation (in 1NF):**
```
COURSE_SCHEDULE(StudentID, StudentName, StudentMajor, DepartmentID, DepartmentName, 
                DepartmentBuilding, CourseID, CourseName, Credits, InstructorID, 
                InstructorName, InstructorRank, Semester, Year, ClassroomID, 
                ClassroomBuilding, ClassroomCapacity, MeetingDay, MeetingTime, Grade)
```

**Sample Data:**
```
| StudentID | StudentName | StudentMajor | DeptID | DeptName | DeptBuilding | CourseID | CourseName    | Credits | InstructorID | InstructorName | InstructorRank | Semester | Year | ClassroomID | ClassroomBuilding | ClassroomCapacity | MeetingDay | MeetingTime | Grade |
|-----------|-------------|--------------|--------|----------|--------------|----------|---------------|---------|--------------|----------------|----------------|----------|------|-------------|-------------------|-------------------|------------|-------------|-------|
| S001      | John Doe    | CS           | D01    | Comp Sci | Engineering  | C101     | Data Struct   | 3       | I201         | Dr. Smith      | Professor      | Fall     | 2024 | R301        | Engineering       | 40                | Monday     | 10:00       | A     |
| S001      | John Doe    | CS           | D01    | Comp Sci | Engineering  | C101     | Data Struct   | 3       | I201         | Dr. Smith      | Professor      | Fall     | 2024 | R301        | Engineering       | 40                | Wednesday  | 10:00       | A     |
| S001      | John Doe    | CS           | D01    | Comp Sci | Engineering  | C102     | Algorithms    | 4       | I202         | Dr. Jones      | Assoc Prof     | Fall     | 2024 | R302        | Engineering       | 35                | Tuesday    | 14:00       | B+    |
| S002      | Jane Smith  | Math         | D02    | Mathematics | Science    | C101     | Data Struct   | 3       | I201         | Dr. Smith      | Professor      | Fall     | 2024 | R301        | Engineering       | 40                | Monday     | 10:00       | B     |
```

**Business Rules:**
1. Each student has a unique StudentID with one name and one major
2. Each student's major is associated with exactly one department
3. Each department has a unique DepartmentID with one name and one building location
4. Each course has a unique CourseID with one name and one credit value
5. Each instructor has a unique InstructorID with one name and one academic rank
6. A course offering is uniquely identified by CourseID + Semester + Year
7. Each course offering is taught by exactly one instructor
8. Each course offering is assigned to exactly one classroom
9. Each classroom has a unique ClassroomID, is located in one building, and has one capacity
10. A course offering meets on multiple days per week (Monday, Wednesday, etc.)
11. All meetings for a course offering occur at the same time (e.g., 10:00)
12. Each student receives one grade per course offering they enroll in
13. The classroom building is determined by the ClassroomID (ClassroomID → ClassroomBuilding, ClassroomCapacity)
14. Multiple course offerings can use the same classroom at different times

**Given Functional Dependencies:**
```
FD1:  StudentID → StudentName, StudentMajor
FD2:  StudentMajor → DepartmentID
FD3:  DepartmentID → DepartmentName, DepartmentBuilding
FD4:  CourseID → CourseName, Credits
FD5:  InstructorID → InstructorName, InstructorRank
FD6:  ClassroomID → ClassroomBuilding, ClassroomCapacity
FD7:  CourseID, Semester, Year → InstructorID, ClassroomID, MeetingTime
FD8:  StudentID, CourseID, Semester, Year → Grade
FD9:  CourseID, Semester, Year, MeetingDay → (this is just the combination that appears, no additional attributes determined beyond FD7)
```

**Candidate Key:**
- `(StudentID, CourseID, Semester, Year, MeetingDay)`

**Your Tasks:**

1. **Verify the relation is in 1NF**
2. **Decompose to 2NF** - Eliminate all partial dependencies
3. **Decompose to 3NF** - Eliminate all transitive dependencies
4. **Decompose to BCNF** - Ensure all determinants are candidate keys
5. **For each decomposition step:**
   - List the resulting relations with their attributes
   - Identify the primary key for each relation
   - State which dependencies are preserved in each relation
   - Verify lossless join property
   - Verify dependency preservation

---

# Solution: Step-by-Step Decomposition

## Step 1: Verify 1NF

**Analysis:**
- All attributes contain atomic (single) values ✓
- No repeating groups ✓
- Each row is unique (identified by StudentID + CourseID + Semester + Year + MeetingDay) ✓
- Note: Each course offering meets multiple times per week, which is why MeetingDay is part of the key

**Conclusion:** The relation is in 1NF.

---

## Step 2: Decompose to 2NF

**Goal:** Eliminate partial dependencies (non-prime attributes dependent on part of the candidate key)

**Candidate Key:** `(StudentID, CourseID, Semester, Year, MeetingDay)`

**Prime Attributes:** StudentID, CourseID, Semester, Year, MeetingDay

**Non-Prime Attributes:** StudentName, StudentMajor, DepartmentID, DepartmentName, DepartmentBuilding, CourseName, Credits, InstructorID, InstructorName, InstructorRank, ClassroomID, ClassroomBuilding, ClassroomCapacity, MeetingTime, Grade

**Partial Dependencies Identified:**

- `StudentID → StudentName, StudentMajor` (FD1) - **PARTIAL DEPENDENCY**
  - Depends on only StudentID (part of the key)

- `StudentMajor → DepartmentID` (FD2) - **TRANSITIVE through StudentID**
  - First: StudentID → StudentMajor (partial)
  - Then: StudentMajor → DepartmentID

- `DepartmentID → DepartmentName, DepartmentBuilding` (FD3) - **TRANSITIVE through StudentMajor**
  - Chain: StudentID → StudentMajor → DepartmentID → DepartmentName, DepartmentBuilding

- `CourseID → CourseName, Credits` (FD4) - **PARTIAL DEPENDENCY**
  - Depends on only CourseID (part of the key)

- `InstructorID → InstructorName, InstructorRank` (FD5) - **TRANSITIVE through (CourseID, Semester, Year)**
  - First: CourseID, Semester, Year → InstructorID
  - Then: InstructorID → InstructorName, InstructorRank

- `ClassroomID → ClassroomBuilding, ClassroomCapacity` (FD6) - **TRANSITIVE through (CourseID, Semester, Year)**
  - First: CourseID, Semester, Year → ClassroomID
  - Then: ClassroomID → ClassroomBuilding, ClassroomCapacity

- `CourseID, Semester, Year → InstructorID, ClassroomID, MeetingTime` (FD7) - **PARTIAL DEPENDENCY**
  - Depends on part of the key (not including StudentID or MeetingDay)

- `StudentID, CourseID, Semester, Year → Grade` (FD8) - **PARTIAL DEPENDENCY**
  - Depends on part of the key (not including MeetingDay)

**Decomposition to 2NF:**

**R1: COURSE_MEETING_2NF** (represents when courses meet)
```
COURSE_MEETING_2NF(CourseID, Semester, Year, MeetingDay, MeetingTime)
Primary Key: (CourseID, Semester, Year, MeetingDay)
FDs preserved: (CourseID, Semester, Year) determines MeetingTime (but MeetingTime repeats for each day)
```

**R2: ENROLLMENT_2NF**
```
ENROLLMENT_2NF(StudentID, CourseID, Semester, Year, Grade)
Primary Key: (StudentID, CourseID, Semester, Year)
FDs preserved: StudentID, CourseID, Semester, Year → Grade
```

**R3: COURSE_OFFERING_2NF**
```
COURSE_OFFERING_2NF(CourseID, Semester, Year, InstructorID, ClassroomID, MeetingTime)
Primary Key: (CourseID, Semester, Year)
FDs preserved: CourseID, Semester, Year → InstructorID, ClassroomID, MeetingTime
```

**R4: STUDENTS_2NF**
```
STUDENTS_2NF(StudentID, StudentName, StudentMajor)
Primary Key: StudentID
FDs preserved: StudentID → StudentName, StudentMajor
```

**R5: COURSES_2NF**
```
COURSES_2NF(CourseID, CourseName, Credits)
Primary Key: CourseID
FDs preserved: CourseID → CourseName, Credits
```

**R6: INSTRUCTORS_2NF**
```
INSTRUCTORS_2NF(InstructorID, InstructorName, InstructorRank)
Primary Key: InstructorID
FDs preserved: InstructorID → InstructorName, InstructorRank
```

**R7: CLASSROOMS_2NF**
```
CLASSROOMS_2NF(ClassroomID, ClassroomBuilding, ClassroomCapacity)
Primary Key: ClassroomID
FDs preserved: ClassroomID → ClassroomBuilding, ClassroomCapacity
```

**R8: MAJORS_2NF**
```
MAJORS_2NF(StudentMajor, DepartmentID)
Primary Key: StudentMajor
FDs preserved: StudentMajor → DepartmentID
```

**R9: DEPARTMENTS_2NF**
```
DEPARTMENTS_2NF(DepartmentID, DepartmentName, DepartmentBuilding)
Primary Key: DepartmentID
FDs preserved: DepartmentID → DepartmentName, DepartmentBuilding
```

**Verification:**

**Lossless Join:**
- Can reconstruct original relation by joining:
  - COURSE_MEETING_2NF ⋈ ENROLLMENT_2NF (on CourseID, Semester, Year)
  - ⋈ COURSE_OFFERING_2NF (on CourseID, Semester, Year)
  - ⋈ STUDENTS_2NF (on StudentID)
  - ⋈ COURSES_2NF (on CourseID)
  - ⋈ INSTRUCTORS_2NF (on InstructorID)
  - ⋈ CLASSROOMS_2NF (on ClassroomID)
  - ⋈ MAJORS_2NF (on StudentMajor)
  - ⋈ DEPARTMENTS_2NF (on DepartmentID)
- Each join uses foreign keys that reference primary keys ✓

**Dependency Preservation:**
- FD1: Preserved in STUDENTS_2NF ✓
- FD2: Preserved in MAJORS_2NF ✓
- FD3: Preserved in DEPARTMENTS_2NF ✓
- FD4: Preserved in COURSES_2NF ✓
- FD5: Preserved in INSTRUCTORS_2NF ✓
- FD6: Preserved in CLASSROOMS_2NF ✓
- FD7: Preserved in COURSE_OFFERING_2NF ✓
- FD8: Preserved in ENROLLMENT_2NF ✓
- All original FDs are preserved ✓

**2NF Check for Each Relation:**
- R1: Candidate key is (CourseID, Semester, Year, MeetingDay), MeetingTime depends on part of key - needs review
- R2: Candidate key is (StudentID, CourseID, Semester, Year), Grade depends on full key ✓
- R3: Candidate key is (CourseID, Semester, Year), all non-key attributes depend on full key ✓
- R4-R9: Single-attribute keys, no partial dependencies possible ✓

[Inference] R1 (COURSE_MEETING_2NF) has an issue: MeetingTime depends on (CourseID, Semester, Year) but not on MeetingDay. This means MeetingTime is repeated for each day. Let me reconsider the decomposition.

**Revised R1:**
```
COURSE_MEETING_2NF(CourseID, Semester, Year, MeetingDay)
Primary Key: (CourseID, Semester, Year, MeetingDay)
Note: MeetingTime moved to COURSE_OFFERING_2NF since it depends on (CourseID, Semester, Year)
```

**Conclusion:** All relations are now in 2NF.

---

## Step 3: Decompose to 3NF

**Goal:** Eliminate transitive dependencies (non-prime attribute → non-prime attribute)

**Analysis of Each 2NF Relation:**

**R1: COURSE_MEETING_2NF(CourseID, Semester, Year, MeetingDay)**
- Candidate Key: (CourseID, Semester, Year, MeetingDay)
- All attributes are key attributes
- No non-key attributes
- No transitive dependencies possible ✓
- **Already in 3NF**

**R2: ENROLLMENT_2NF(StudentID, CourseID, Semester, Year, Grade)**
- Candidate Key: (StudentID, CourseID, Semester, Year)
- FD: StudentID, CourseID, Semester, Year → Grade
- Grade depends directly on the key
- No transitive dependencies ✓
- **Already in 3NF**

**R3: COURSE_OFFERING_2NF(CourseID, Semester, Year, InstructorID, ClassroomID, MeetingTime)**
- Candidate Key: (CourseID, Semester, Year)
- FDs: CourseID, Semester, Year → InstructorID, ClassroomID, MeetingTime
- However, we have:
  - InstructorID → InstructorName, InstructorRank (FD5) - but these attributes are not in this relation
  - ClassroomID → ClassroomBuilding, ClassroomCapacity (FD6) - but these attributes are not in this relation
- No transitive dependencies within this relation ✓
- **Already in 3NF**

**R4: STUDENTS_2NF(StudentID, StudentName, StudentMajor)**
- Candidate Key: StudentID
- FDs: 
  - StudentID → StudentName, StudentMajor (direct)
  - StudentMajor → DepartmentID (FD2) - but DepartmentID is not in this relation anymore
- Within this relation: does StudentName determine StudentMajor? No.
- Does StudentMajor determine StudentName? No.
- No transitive dependencies within this relation ✓
- **Already in 3NF**

**R5: COURSES_2NF(CourseID, CourseName, Credits)**
- Candidate Key: CourseID
- FD: CourseID → CourseName, Credits
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R6: INSTRUCTORS_2NF(InstructorID, InstructorName, InstructorRank)**
- Candidate Key: InstructorID
- FD: InstructorID → InstructorName, InstructorRank
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R7: CLASSROOMS_2NF(ClassroomID, ClassroomBuilding, ClassroomCapacity)**
- Candidate Key: ClassroomID
- FD: ClassroomID → ClassroomBuilding, ClassroomCapacity
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**R8: MAJORS_2NF(StudentMajor, DepartmentID)**
- Candidate Key: StudentMajor
- FD: StudentMajor → DepartmentID
- Only one non-key attribute
- No transitive dependencies possible ✓
- **Already in 3NF**

**R9: DEPARTMENTS_2NF(DepartmentID, DepartmentName, DepartmentBuilding)**
- Candidate Key: DepartmentID
- FD: DepartmentID → DepartmentName, DepartmentBuilding
- No non-key attribute determines another non-key attribute
- No transitive dependencies ✓
- **Already in 3NF**

**3NF Relations (Same as 2NF):**

```
COURSE_MEETING_3NF(CourseID, Semester, Year, MeetingDay)
Primary Key: (CourseID, Semester, Year, MeetingDay)

ENROLLMENT_3NF(StudentID, CourseID, Semester, Year, Grade)
Primary Key: (StudentID, CourseID, Semester, Year)

COURSE_OFFERING_3NF(CourseID, Semester, Year, InstructorID, ClassroomID, MeetingTime)
Primary Key: (CourseID, Semester, Year)

STUDENTS_3NF(StudentID, StudentName, StudentMajor)
Primary Key: StudentID

COURSES_3NF(CourseID, CourseName, Credits)
Primary Key: CourseID

INSTRUCTORS_3NF(InstructorID, InstructorName, InstructorRank)
Primary Key: InstructorID

CLASSROOMS_3NF(ClassroomID, ClassroomBuilding, ClassroomCapacity)
Primary Key: ClassroomID

MAJORS_3NF(StudentMajor, DepartmentID)
Primary Key: StudentMajor

DEPARTMENTS_3NF(DepartmentID, DepartmentName, DepartmentBuilding)
Primary Key: DepartmentID
```

**Verification:**

**Lossless Join:** Same as 2NF verification ✓

**Dependency Preservation:** All FDs still preserved ✓

**3NF Check:**
- No non-prime attribute transitively depends on any candidate key ✓
- For each FD X → A: either X is a superkey, OR A is a prime attribute ✓
- All relations satisfy 3NF conditions ✓

**Conclusion:** All relations are in 3NF. The 2NF decomposition properly separated entities, which eliminated transitive dependencies.

---

## Step 4: Decompose to BCNF

**Goal:** Ensure every determinant is a candidate key

**BCNF Requirement:** For every non-trivial FD X → Y, X must be a superkey.

**Analysis of Each 3NF Relation:**

**R1: COURSE_MEETING_3NF(CourseID, Semester, Year, MeetingDay)**
- Candidate Key: (CourseID, Semester, Year, MeetingDay)
- All attributes are part of the key
- No non-trivial FDs with non-superkey determinants
- **In BCNF**

**R2: ENROLLMENT_3NF(StudentID, CourseID, Semester, Year, Grade)**
- Candidate Key: (StudentID, CourseID, Semester, Year)
- FD: StudentID, CourseID, Semester, Year → Grade
- Determinant is a candidate key ✓
- **In BCNF**

**R3: COURSE_OFFERING_3NF(CourseID, Semester, Year, InstructorID, ClassroomID, MeetingTime)**
- Candidate Key: (CourseID, Semester, Year)
- FD: CourseID, Semester, Year → InstructorID, ClassroomID, MeetingTime
- Determinant is a candidate key ✓
- **In BCNF**

**R4: STUDENTS_3NF(StudentID, StudentName, StudentMajor)**
- Candidate Key: StudentID
- FD: StudentID → StudentName, StudentMajor
- Determinant is a candidate key ✓
- **In BCNF**

**R5: COURSES_3NF(CourseID, CourseName, Credits)**
- Candidate Key: CourseID
- FD: CourseID → CourseName, Credits
- Determinant is a candidate key ✓
- **In BCNF**

**R6: INSTRUCTORS_3NF(InstructorID, InstructorName, InstructorRank)**
- Candidate Key: InstructorID
- FD: InstructorID → InstructorName, InstructorRank
- Determinant is a candidate key ✓
- **In BCNF**

**R7: CLASSROOMS_3NF(ClassroomID, ClassroomBuilding, ClassroomCapacity)**
- Candidate Key: ClassroomID
- FD: ClassroomID → ClassroomBuilding, ClassroomCapacity
- Determinant is a candidate key ✓
- **In BCNF**

**R8: MAJORS_3NF(StudentMajor, DepartmentID)**
- Candidate Key: StudentMajor
- FD: StudentMajor → DepartmentID
- Determinant is a candidate key ✓
- **In BCNF**

**R9: DEPARTMENTS_3NF(DepartmentID, DepartmentName, DepartmentBuilding)**
- Candidate Key: DepartmentID
- FD: DepartmentID → DepartmentName, DepartmentBuilding
- Determinant is a candidate key ✓
- **In BCNF**

**BCNF Relations (Same as 3NF):**

```
COURSE_MEETING_BCNF(CourseID, Semester, Year, MeetingDay)
Primary Key: (CourseID, Semester, Year, MeetingDay)
Foreign Key: (CourseID, Semester, Year) references COURSE_OFFERING_BCNF

ENROLLMENT_BCNF(StudentID, CourseID, Semester, Year, Grade)
Primary Key: (StudentID, CourseID, Semester, Year)
Foreign Keys:
  - StudentID references STUDENTS_BCNF
  - (CourseID, Semester, Year) references COURSE_OFFERING_BCNF

COURSE_OFFERING_BCNF(CourseID, Semester, Year, InstructorID, ClassroomID, MeetingTime)
Primary Key: (CourseID, Semester, Year)
Foreign Keys:
  - CourseID references COURSES_BCNF
  - InstructorID references INSTRUCTORS_BCNF
  - ClassroomID references CLASSROOMS_BCNF

STUDENTS_BCNF(StudentID, StudentName, StudentMajor)
Primary Key: StudentID
Foreign Key: StudentMajor references MAJORS_BCNF

COURSES_BCNF(CourseID, CourseName, Credits)
Primary Key: CourseID

INSTRUCTORS_BCNF(InstructorID, InstructorName, InstructorRank)
Primary Key: InstructorID

CLASSROOMS_BCNF(ClassroomID, ClassroomBuilding, ClassroomCapacity)
Primary Key: ClassroomID

MAJORS_BCNF(StudentMajor, DepartmentID)
Primary Key: StudentMajor
Foreign Key: DepartmentID references DEPARTMENTS_BCNF

DEPARTMENTS_BCNF(DepartmentID, DepartmentName, DepartmentBuilding)
Primary Key: DepartmentID
```

**Verification:**

**Lossless Join:**
- Original relation can be reconstructed by natural joins ✓
- Join path: COURSE_MEETING_BCNF ⋈ ENROLLMENT_BCNF ⋈ COURSE_OFFERING_BCNF ⋈ STUDENTS_BCNF ⋈ COURSES_BCNF ⋈ INSTRUCTORS_BCNF ⋈ CLASSROOMS_BCNF ⋈ MAJORS_BCNF ⋈ DEPARTMENTS_BCNF

**Dependency Preservation:**
- All original FDs are preserved across the relations ✓

**BCNF Check:**
- Every determinant in every FD is a candidate key ✓

**Conclusion:** All relations are in BCNF.

---

## Summary of Decomposition

**Original Relation:**
- 1 relation with 20 attributes
- Candidate key: (StudentID, CourseID, Semester, Year, MeetingDay) - 5 attributes
- Multiple partial and transitive dependencies

**Final BCNF Schema:**
- 9 relations
- No partial dependencies
- No transitive dependencies
- All determinants are candidate keys
- Lossless join preserved
- All dependencies preserved

**Key Transformations:**

1. **1NF → 2NF:** Separated partial dependencies by creating relations for entities (STUDENTS, COURSES, INSTRUCTORS, CLASSROOMS, DEPARTMENTS, MAJORS) and relationships (ENROLLMENT, COURSE_OFFERING, COURSE_MEETING)
2. **2NF → 3NF:** No additional decomposition needed (proper entity separation already eliminated transitive dependencies)
3. **3NF → BCNF:** No additional decomposition needed (all determinants were already candidate keys)

**Benefits of Normalization:**

1. **Eliminated Update Anomalies:**
   - Changing instructor rank: Update only INSTRUCTORS_BCNF (one place)
   - Changing classroom capacity: Update only CLASSROOMS_BCNF (one place)
   - Changing department building: Update only DEPARTMENTS_BCNF (one place)
   - Changing course credits: Update only COURSES_BCNF (one place)

2. **Eliminated Insertion Anomalies:**
   - Can add a new student without enrolling them in courses
   - Can add a new course without offering it in any semester
   - Can add a new instructor without assigning courses
   - Can add a new classroom without scheduling any classes
   - Can add a new department without having students in that major
   - Can add a new major without having students

3. **Eliminated Deletion Anomalies:**
   - Deleting all enrollments for a student doesn't lose student information
   - Deleting all course offerings doesn't lose course definitions
   - Deleting all course offerings taught by an instructor doesn't lose instructor information
   - Deleting all classes in a classroom doesn't lose classroom information
   - Deleting all students in a major doesn't lose major-to-department mapping

4. **Reduced Redundancy:**
   - Student information stored once per student (not per enrollment per meeting day)
   - Instructor information stored once per instructor (not per course offering per meeting day)
   - Course information stored once per course (not per offering per student per meeting day)
   - Classroom information stored once per classroom (not per course offering per meeting day)
   - Department information stored once per department (not per student per enrollment)

5. **Improved Data Integrity:**
   - Referential integrity enforced through foreign keys
   - Consistent course credits across all offerings
   - Consistent instructor ranks across all assignments
   - Consistent classroom capacities across all uses

**Storage Comparison:**

Original (denormalized):
- 4 rows × 20 attributes = 80 attribute values (with massive redundancy)
- Note: John Doe's CS 101 appears twice (Monday and Wednesday), duplicating 18 of 20 attributes

Normalized (BCNF):
- COURSE_MEETING_BCNF: 3 rows × 4 = 12 values (C101 meets Mon & Wed, C102 meets Tue)
- ENROLLMENT_BCNF: 3 rows × 5 = 15 values (S001 in C101, S001 in C102, S002 in C101)
- COURSE_OFFERING_BCNF: 2 rows × 6 = 12 values (C101 Fall 2024, C102 Fall 2024)
- STUDENTS_BCNF: 2 rows × 3 = 6 values (S001, S002)
- COURSES_BCNF: 2 rows × 3 = 6 values (C101, C102)
- INSTRUCTORS_BCNF: 2 rows × 3 = 6 values (I201, I202)
- CLASSROOMS_BCNF: 2 rows × 3 = 6 values (R301, R302)
- MAJORS_BCNF: 2 rows × 2 = 4 values (CS → D01, Math → D02)
- DEPARTMENTS_BCNF: 2 rows × 3 = 6 values (D01, D02)
- **Total: 73 attribute values** (with zero redundancy)

[Inference] The normalized schema stores only 73 values compared to 80 in the denormalized version, but more importantly, there is zero redundancy. In a real university system with thousands of students and hundreds of courses, the savings would be massive.

**Real-World Implications:**

- **Scalability:** With 10,000 students and 1,000 course offerings, normalized schema saves enormous storage
- **Maintainability:** Changing an instructor's rank updates one row instead of potentially thousands
- **Data Quality:** Prevents inconsistent student names, course credits, or classroom capacities
- **Flexibility:** Easy to add new semesters, courses, students, or instructors independently
- **Query Efficiency:** While joins are required, indexes on foreign keys make queries efficient
- **Academic Operations:** Supports complex queries like "find all classrooms in Engineering building" or "list all students in CS major" efficiently

**Complex Query Examples Enabled by Normalization:**

1. Find all courses taught by professors (rank = 'Professor'): Join COURSE_OFFERING ⋈ INSTRUCTORS
2. Find students in majors housed in Science building: Join STUDENTS ⋈ MAJORS ⋈ DEPARTMENTS
3. Find classroom utilization: Join COURSE_OFFERING ⋈ COURSE_MEETING ⋈ CLASSROOMS
4. Find grade distribution by instructor rank: Join ENROLLMENT ⋈ COURSE_OFFERING ⋈ INSTRUCTORS

---

# Understanding When 2NF ≠ 3NF and When 3NF ≠ BCNF

## Part 1: When 2NF Does NOT Guarantee 3NF

### The Key Difference

**2NF eliminates:** Partial dependencies (non-prime attribute depending on part of candidate key)

**3NF eliminates:** Transitive dependencies (non-prime attribute depending on another non-prime attribute)

### Critical Condition for 2NF ≠ 3NF

A relation in 2NF will violate 3NF when:

**There exists a transitive dependency chain where a non-prime attribute determines another non-prime attribute.**

Pattern: `Candidate Key → Non-Prime Attribute X → Non-Prime Attribute Y`

This occurs when you have **embedded entity references** within a relation that are not separated during 2NF decomposition.

---

## Concrete Example 1: Employee Department Manager

**Relation in 2NF but NOT in 3NF:**

```
EMPLOYEE_PROJECT(EmployeeID, ProjectID, DepartmentID, DepartmentManager, HoursWorked)
```

**Functional Dependencies:**
```
FD1: EmployeeID, ProjectID → DepartmentID, HoursWorked
FD2: DepartmentID → DepartmentManager
```

**Candidate Key:** `(EmployeeID, ProjectID)`

**Analysis:**

**2NF Check:**
- Candidate key: (EmployeeID, ProjectID)
- DepartmentID depends on the full key ✓
- HoursWorked depends on the full key ✓
- No partial dependencies ✓
- **In 2NF** ✓

**3NF Check:**
- DepartmentID is a non-prime attribute
- DepartmentManager is a non-prime attribute
- `DepartmentID → DepartmentManager` creates a transitive dependency
- Chain: `(EmployeeID, ProjectID) → DepartmentID → DepartmentManager`
- DepartmentManager transitively depends on the candidate key through DepartmentID
- **VIOLATES 3NF** ✗

**Why This Happens:**
- During 2NF decomposition, DepartmentID was correctly kept with the full key
- However, DepartmentID acts as an embedded reference to another entity (Department)
- The relationship `DepartmentID → DepartmentManager` is a functional dependency within the Department entity
- This transitive dependency was not eliminated during 2NF decomposition

**Solution for 3NF:**
```
EMPLOYEE_PROJECT_3NF(EmployeeID, ProjectID, DepartmentID, HoursWorked)
Primary Key: (EmployeeID, ProjectID)

DEPARTMENTS_3NF(DepartmentID, DepartmentManager)
Primary Key: DepartmentID
```

---

## Concrete Example 2: Student Course Instructor

**Relation in 2NF but NOT in 3NF:**

```
ENROLLMENT(StudentID, CourseID, InstructorID, InstructorOffice, Grade)
```

**Functional Dependencies:**
```
FD1: StudentID, CourseID → InstructorID, Grade
FD2: InstructorID → InstructorOffice
```

**Candidate Key:** `(StudentID, CourseID)`

**Analysis:**

**2NF Check:**
- InstructorID depends on full key (StudentID, CourseID) ✓
- Grade depends on full key ✓
- No partial dependencies ✓
- **In 2NF** ✓

**3NF Check:**
- Transitive dependency: `(StudentID, CourseID) → InstructorID → InstructorOffice`
- InstructorOffice depends on InstructorID, not directly on the candidate key
- **VIOLATES 3NF** ✗

**Solution for 3NF:**
```
ENROLLMENT_3NF(StudentID, CourseID, InstructorID, Grade)
Primary Key: (StudentID, CourseID)

INSTRUCTORS_3NF(InstructorID, InstructorOffice)
Primary Key: InstructorID
```

---

## Concrete Example 3: Order with Computed Total

**Relation in 2NF but NOT in 3NF:**

```
ORDER_ITEMS(OrderID, ProductID, Quantity, UnitPrice, ItemTotal, OrderTotal)
```

**Functional Dependencies:**
```
FD1: OrderID, ProductID → Quantity, UnitPrice
FD2: OrderID, ProductID, Quantity, UnitPrice → ItemTotal (computed: Quantity × UnitPrice)
FD3: OrderID → OrderTotal
```

**Candidate Key:** `(OrderID, ProductID)`

**Analysis:**

**2NF Check:**
- Quantity and UnitPrice depend on full key ✓
- ItemTotal depends on full key (even though computed) ✓
- OrderTotal depends on only OrderID - **PARTIAL DEPENDENCY** ✗

[Correction] This example violates 2NF due to the partial dependency `OrderID → OrderTotal`. Let me provide a corrected version.

**Corrected Relation (properly in 2NF):**

After 2NF decomposition:
```
ORDER_ITEMS_2NF(OrderID, ProductID, Quantity, UnitPrice, ItemTotal)
```

**Functional Dependencies:**
```
FD1: OrderID, ProductID → Quantity, UnitPrice, ItemTotal
FD2: Quantity, UnitPrice → ItemTotal (ItemTotal = Quantity × UnitPrice)
```

**Candidate Key:** `(OrderID, ProductID)`

**Analysis:**

**2NF Check:**
- All non-prime attributes depend on the full key ✓
- **In 2NF** ✓

**3NF Check:**
- Transitive dependency: `(OrderID, ProductID) → Quantity, UnitPrice → ItemTotal`
- ItemTotal is determined by Quantity and UnitPrice (both non-prime attributes)
- **VIOLATES 3NF** ✗

[Inference] This is a special case where a computed/derived attribute creates a transitive dependency even though all inputs are part of the same relation.

---

## Summary: Conditions for 2NF → 3NF Violation

A relation in 2NF will **violate 3NF** when:

1. **Non-prime attribute acts as a foreign key** to another entity, and attributes of that entity are included in the relation
   - Example: DepartmentID (non-prime) → DepartmentManager

2. **Non-prime attributes have functional dependencies among themselves**
   - Example: Quantity, UnitPrice (non-prime) → ItemTotal (non-prime)

3. **Embedded entity attributes** are not separated during 2NF decomposition
   - This happens when the foreign key and its related attributes are all correctly dependent on the full candidate key, so 2NF doesn't catch it

4. **The relation has a composite key AND contains reference attributes from related entities**
   - The reference attribute (like InstructorID) depends on the full key
   - But other attributes of that referenced entity (like InstructorOffice) also appear in the relation

---

## Part 2: When 3NF Does NOT Guarantee BCNF

### The Key Difference

**3NF allows:** A non-prime attribute to depend on a non-superkey, AS LONG AS that non-prime attribute is part of some candidate key

**BCNF requires:** ALL determinants must be superkeys (no exceptions)

### Critical Condition for 3NF ≠ BCNF

A relation in 3NF will violate BCNF when:

**There exists an FD `X → A` where:**
1. X is NOT a superkey
2. A is a prime attribute (part of some candidate key)
3. There are multiple overlapping candidate keys

This typically occurs when there are **multiple candidate keys that overlap** (share common attributes).

---

## Concrete Example 1 (Definitive Version): Student Tutor Subject

**Relation in 3NF but NOT in BCNF:**

```
TUTORING(StudentID, Subject, TutorID)
```

**Business Rules:**
- Each student can be tutored in multiple subjects
- Each subject can have multiple students
- Each tutor teaches exactly one subject (specialization)
- For a given subject, multiple tutors are available
- A student studying a subject is assigned exactly one tutor
- A tutor can tutor multiple students (in their specialized subject only)

**Functional Dependencies:**
```
FD1: StudentID, Subject → TutorID
FD2: TutorID → Subject
```

**Finding Candidate Keys:**

From FD2: TutorID → Subject

To find all attributes, need to include StudentID
- Can `(StudentID, Subject)` determine all attributes?
  - StudentID, Subject → TutorID (FD1) ✓
  - TutorID → Subject (FD2, but Subject already known) ✓
  - Yes, `(StudentID, Subject)` is a candidate key

- Can `(StudentID, TutorID)` determine all attributes?
  - TutorID → Subject (FD2) ✓
  - StudentID, Subject → TutorID (but we already have TutorID) ✓
  - StudentID, TutorID → TutorID (obvious) ✓
  - Yes, `(StudentID, TutorID)` is a candidate key

**Candidate Keys:**
- `(StudentID, Subject)`
- `(StudentID, TutorID)`

**Prime Attributes:** StudentID, Subject, TutorID (all are prime!)

**Non-Prime Attributes:** None

**Analysis:**

**3NF Check:**
- No non-prime attributes exist ✓
- For FD1: `StudentID, Subject → TutorID`
  - Left side is a candidate key (superkey) ✓
- For FD2: `TutorID → Subject`
  - Left side (TutorID) is NOT a superkey ✗
  - BUT Subject is a prime attribute (part of candidate key `(StudentID, Subject)`) ✓
  - **3NF allows this!** When the determinant is not a superkey, 3NF permits it if the dependent attribute is prime ✓
- **In 3NF** ✓

**BCNF Check:**
- For FD2: `TutorID → Subject`
  - Left side (TutorID) is NOT a superkey ✗
  - **BCNF requires ALL determinants to be superkeys** ✗
  - **VIOLATES BCNF** ✗

**Why This Violates BCNF but Not 3NF:**
- TutorID is not a candidate key (it doesn't uniquely identify a tutoring session)
- But TutorID → Subject is a valid dependency (each tutor specializes in one subject)
- Subject is prime (part of candidate key), so 3NF allows this
- BCNF has no exceptions - TutorID must be a superkey to be a determinant, which it isn't

**Solution for BCNF:**
```
TUTORING_BCNF(StudentID, TutorID)
Primary Key: (StudentID, TutorID)

TUTOR_SPECIALIZATION_BCNF(TutorID, Subject)
Primary Key: TutorID
```

**Consequence of BCNF Decomposition:**
- We can no longer verify the FD `StudentID, Subject → TutorID` without joining the tables
- This is **dependency loss** - a known trade-off when decomposing to BCNF
- [Unverified] In some cases, BCNF decomposition may not preserve all functional dependencies

---

## Concrete Example 2: Employee Skills Certification

**Relation in 3NF but NOT in BCNF:**

```
EMPLOYEE_SKILLS(EmployeeID, SkillName, CertificationBody)
```

**Business Rules:**
- Employees can have multiple skills
- Each skill can be possessed by multiple employees
- Each skill has exactly one official certification body (e.g., "Java" → "Oracle")
- An employee with a skill is certified by that skill's official body
- Different skills have different certification bodies

**Functional Dependencies:**
```
FD1: EmployeeID, SkillName → CertificationBody
FD2: SkillName → CertificationBody
```

**Candidate Keys:**
- `(EmployeeID, SkillName)` is the only candidate key

**Prime Attributes:** EmployeeID, SkillName

**Non-Prime Attributes:** CertificationBody

**Analysis:**

**3NF Check:**
- For FD1: `EmployeeID, SkillName → CertificationBody`
  - Left side is a candidate key ✓
- For FD2: `SkillName → CertificationBody`
  - Left side (SkillName) is NOT a superkey ✗
  - CertificationBody is a non-prime attribute ✗
  - **VIOLATES 3NF** ✗

[Correction] This example actually violates 3NF because CertificationBody is non-prime and SkillName is not a superkey.

---

## Why Is It Hard to Find 3NF → BCNF Violations?

The key insight: **For a relation to be in 3NF but not BCNF:**

1. **ALL attributes must be prime** (part of some candidate key), OR
2. The violating FD must have a prime attribute on the right side

This is rare because:
- Most relations have clear non-prime attributes
- When non-prime attributes exist, transitive dependencies usually violate 3NF first
- BCNF violations typically occur with complex, overlapping candidate keys where all attributes are prime

---

## Definitive Correct Example: Zip Code City State

**Relation in 3NF but NOT in BCNF:**

```
ADDRESS_INFO(ZipCode, City, State)
```

**Business Rules:**
- Each zip code belongs to exactly one city
- Each zip code belongs to exactly one state
- Each city can be in only one state
- Multiple zip codes can exist in the same city
- Multiple cities can exist in the same state (e.g., Springfield in many states)

**Functional Dependencies:**
```
FD1: ZipCode → City, State
FD2: City, State → (nothing new, but City, State doesn't determine ZipCode uniquely)
FD3: ZipCode → City
FD4: ZipCode → State
FD5: City, State → ZipCode (ONLY if we assume city names are unique within a state - this creates multiple candidate keys)
```

**Wait, let me reconsider the business rules.**

[Inference] If (City, State) uniquely identifies a ZipCode, then we'd have two candidate keys. But in reality, a city can have multiple zip codes, so (City, State) is not a candidate key.

Let me use the definitive classic example:

---

## The Classic Example: Today's Date (from Date Theory)

**Relation in 3NF but NOT in BCNF:**

```
TODAY(StudentName, DateOfBirth, Age)
```

**Business Rules:**
- StudentName is unique (for simplicity)
- Each student has exactly one date of birth
- Age is computed from DateOfBirth based on today's date
- For any given DateOfBirth, the Age is determined (given today's date is fixed)

**Functional Dependencies:**
```
FD1: StudentName → DateOfBirth, Age
FD2: DateOfBirth → Age (given today's date is constant)
FD3: Age → DateOfBirth (FALSE - multiple birthdates can produce same age)
```

Actually, FD3 is false, so this doesn't create overlapping candidate keys.

---

## The REAL Classic Example: ZIP Code Problem (Corrected)

**Relation in 3NF but NOT in BCNF:**

```
LOCATION(StreetAddress, City, ZipCode)
```

**Business Rules:**
- Each complete street address (like "123 Main St") is in exactly one city
- Each street address has exactly one zip code
- Each zip code is in exactly one city
- Multiple street addresses can share the same zip code
- **Key insight:** Knowing the city and street name uniquely identifies the zip code
- But knowing just the zip code tells you the city

**Functional Dependencies:**
```
FD1: StreetAddress, City → ZipCode
FD2: StreetAddress, ZipCode → City
FD3: ZipCode → City
```

**Candidate Keys:**
- `(StreetAddress, City)`
- `(StreetAddress, ZipCode)`

**Prime Attributes:** StreetAddress, City, ZipCode (all are prime!)

**Non-Prime Attributes:** None

**Analysis:**

**3NF Check:**
- For FD1: Left side `(StreetAddress, City)` is a superkey ✓
- For FD2: Left side `(StreetAddress, ZipCode)` is a superkey ✓
- For FD3: `ZipCode → City`
  - Left side (ZipCode) is NOT a superkey ✗
  - City IS a prime attribute (part of candidate key) ✓
  - **3NF allows this!** ✓
- **In 3NF** ✓

**BCNF Check:**
- For FD3: `ZipCode → City`
  - Left side (ZipCode) is NOT a superkey ✗
  - **VIOLATES BCNF** ✗

**Solution for BCNF:**
```
LOCATION_BCNF_1(StreetAddress, ZipCode)
Primary Key: (StreetAddress, ZipCode)

LOCATION_BCNF_2(ZipCode, City)
Primary Key: ZipCode
```

**Dependency Preservation Check:**
- FD1: `StreetAddress, City → ZipCode` - **LOST!** Cannot verify without joining
- FD2: `StreetAddress, ZipCode → City` - Preserved via join ✓
- FD3: `ZipCode → City` - Preserved in LOCATION_BCNF_2 ✓

**This demonstrates dependency loss in BCNF decomposition!**

---

## Summary: Conditions for 3NF → BCNF Violation

A relation in 3NF will **violate BCNF** when:

1. **There are multiple overlapping candidate keys** (sharing common attributes)

2. **All attributes are prime** (part of at least one candidate key), OR the violating dependency has a prime attribute on the right side

3. **A proper subset of a candidate key determines another part of a different candidate key**
   - Example: ZipCode (part of one candidate key) → City (part of another candidate key)

4. **The dependency is semantically valid but creates redundancy**
   - ZipCode → City is true in the real world
   - But storing both City and ZipCode together creates redundancy

5. **Key Pattern:**
   ```
   Candidate Key 1: (A, B)
   Candidate Key 2: (A, C)
   Functional Dependency: C → B (where C is not a superkey)
   ```

---

## Practical Recognition Rules

**To identify 3NF but not BCNF:**

1. Look for relations where **ALL attributes are prime** (this is a strong indicator)

2. Check if there are **multiple candidate keys that overlap**

3. Look for FDs where:
   - The determinant is a proper subset of some candidate key
   - The determined attribute is part of a different candidate key
   - The determinant is NOT a superkey

4. Common domains:
   - **Geographical data** (zip codes, cities, states)
   - **Scheduling with constraints** (student-tutor-subject, court-time-booking)
   - **Hierarchical relationships** where multiple paths exist to identify entities

**The tutoring and location examples are the classic textbook cases of 3NF ≠ BCNF.**

---

# Database Concurrency Anomalies: Analogies

## Lost Updates
**Analogy**: Two people editing a shared document

Imagine you and a colleague both open the same document at 9:00 AM. You both see "Budget: $1000". You change it to $1200 and save at 9:05. Your colleague changes it to $800 and saves at 9:06. The final value is $800—your update is lost because your colleague's save overwrote yours without seeing your change.

## Dirty Reads
**Analogy**: Reading a draft email before it's finalized

Your colleague is writing an email saying "The project is canceled." You peek at their screen and see this message. Based on this, you tell your team the project is canceled. But then your colleague changes their mind, deletes that sentence, and sends "The project continues as planned." You acted on information that was never officially committed—a "dirty" read of uncommitted data.

## Non-Repeatable Reads
**Analogy**: Checking your bank balance twice during a transaction

At 9:00 AM, you check your account balance: $1000. While you're deciding whether to make a purchase, someone else deposits $500 into your account at 9:02 AM. At 9:05 AM, you check again: $1500. The same query gave you different results because the data changed between your reads—it's "non-repeatable."

## Phantom Reads
**Analogy**: Counting inventory while items are being added

You count how many red shirts are in the warehouse and find 10. While you're preparing your report, someone adds 5 more red shirts. You count again using the same criteria ("all red shirts") and now find 15. New rows appeared that match your search criteria—these are "phantom" rows that materialized between your queries.

---

**Key Distinction**: 
- **Lost updates**: Two transactions modify, one overwrites the other
- **Dirty reads**: Reading uncommitted changes that may be rolled back
- **Non-repeatable reads**: Same row changes value between reads
- **Phantom reads**: The set of rows matching a condition changes between reads

---

# Database Isolation Levels: Analogies

## Read Uncommitted
**Analogy**: Reading someone's rough draft while they're still writing

You're allowed to look at anyone's work-in-progress notes, even while they're actively editing them. You might see "Fire John" written down, act on it, then discover they changed it to "Promote John" before finalizing. You see everything, including mistakes they haven't committed to yet—maximum speed, maximum chaos.

**What it prevents**: Nothing
**What it allows**: Lost updates, dirty reads, non-repeatable reads, phantom reads

## Read Committed
**Analogy**: Only reading finalized, published documents

You can only see documents after someone hits "Publish." If they're working on a draft, you can't see it until they commit to it. However, if you read a published document at 9:00 AM, someone might update and republish it, and when you check again at 9:05 AM, you'll see the new version. You never see drafts, but published content can change between your reads.

**What it prevents**: Dirty reads
**What it allows**: Lost updates, non-repeatable reads, phantom reads

## Repeatable Read
**Analogy**: Taking a snapshot of a magazine issue

When you start reading, it's like you receive a specific magazine issue (January 2024). Even if the publisher releases a new issue (February 2024) while you're reading, you keep seeing the January version. You can re-read the same article and it's always identical. However, if the February issue adds a new article section that would match your search, you won't see it—but you also won't see it appear mid-read like a phantom.

[Inference: The exact behavior with phantoms varies by database implementation]

**What it prevents**: Dirty reads, non-repeatable reads
**What it allows**: Lost updates, phantom reads (in some implementations)

## Serializable
**Analogy**: Taking turns with exclusive access to a file cabinet

Imagine a filing cabinet where only one person can access a drawer at a time, and they lock it until completely finished. If you're counting all files with "Project X" on them, nobody can add, remove, or modify Project X files until you're done. Everyone gets their turn, but it's perfectly orderly—as if all transactions happened one after another in a single-file line.

**What it prevents**: Lost updates, dirty reads, non-repeatable reads, phantom reads
**What it allows**: Nothing (highest isolation)

---

**Key Pattern**: Each level adds more "locking" or "snapshot stability":
- **Read Uncommitted**: See everything in real-time, even chaos
- **Read Committed**: See only finalized work, but it can change between your looks
- **Repeatable Read**: Your view is frozen for individual rows/records
- **Serializable**: Your entire operation is frozen in time—total consistency

**Trade-off**: Higher isolation = more consistency, but lower concurrency/performance

---

# Conflict Serializability

**Conflict serializability** is a concept from database theory that determines whether a schedule (an ordering of operations from multiple transactions) is "safe" - meaning it produces the same result as if the transactions had run one at a time in some order.

## The Core Idea

Two operations **conflict** if:
1. They belong to different transactions
2. They access the same data item
3. At least one of them is a write operation

A schedule is **conflict serializable** if you can transform it into a serial schedule (transactions running one after another) by swapping non-conflicting operations.

## Analogy: The Shared Whiteboard

Imagine a whiteboard that multiple people are using simultaneously:

**Scenario**: Alice and Bob both need to update project statistics on a whiteboard.

- **Alice's task**: Read the current total (50), add her team's contribution (+10), write back 60
- **Bob's task**: Read the current total (50), add his team's contribution (+20), write back 70

### Non-serializable (problematic) schedule:
1. Alice reads 50
2. Bob reads 50
3. Alice writes 60
4. Bob writes 70

**Problem**: The final answer is 70, but it should be 80! Bob's write overwrote Alice's update because they both read the same starting value.

### Conflict serializable schedule:
1. Alice reads 50
2. Alice writes 60
3. Bob reads 60
4. Bob writes 80

This is equivalent to "Alice goes first, then Bob" - a serial schedule. The operations were reordered, but only by swapping non-conflicting ones (operations that don't interfere with each other).

## Why It Matters

Conflict serializability guarantees **consistency** - the database ends up in the same state as if transactions ran one at a time, avoiding issues like the lost update in the whiteboard example.

---

# Two-Phase Locking Variants and Conservative 2PL

## Basic Two-Phase Locking (Basic 2PL)

**What it does:**
- Divides transaction execution into two phases:
  - **Growing phase**: Transaction acquires locks but cannot release any
  - **Shrinking phase**: Transaction releases locks but cannot acquire any
- Once the first lock is released, no new locks can be acquired

**Problem it solves:**
- Guarantees conflict serializability (the schedule is equivalent to some serial execution of transactions)

**Problem it does NOT solve:**
- Does not prevent cascading aborts (if T1 holds a lock, T2 reads T1's uncommitted data, then T1 aborts, T2 must also abort)
- Does not prevent deadlocks

**Example:**
```
T1: Lock(A), Read(A), Lock(B), Write(A), Unlock(A), Read(B), Write(B), Unlock(B), Commit
                      [Growing Phase ↑]  [Shrinking Phase ↑              ]

T2: Lock(A), Read(A), ... (reads uncommitted value if T1 hasn't committed)
```

**Cascading abort scenario:**
```
T1: Lock(A), Write(A=100), Unlock(A) ... [T1 aborts before commit]
T2:                        Lock(A), Read(A=100) ... 
    [T2 must abort because it read uncommitted data]
```

**Deadlock scenario:**
```
T1: Lock(A), ... needs Lock(B)
T2: Lock(B), ... needs Lock(A)
[Deadlock: both wait forever]
```

---

## Strict Two-Phase Locking (Strict 2PL)

**What it does:**
- Extends Basic 2PL with an additional constraint:
  - All **exclusive (write) locks** must be held until the transaction commits or aborts
- Shared (read) locks can still be released during execution

**Problem it solves:**
- Prevents cascading aborts caused by reading uncommitted writes
- Guarantees conflict serializability (like Basic 2PL)
- Simplifies recovery (no need to undo changes made by other transactions)

**Problem it does NOT solve:**
- Does not prevent deadlocks
- Does not prevent all cascading aborts (shared locks can still be released early, potentially causing issues in some scenarios)

**Example:**
```
T1: X-Lock(A), Write(A=100), S-Lock(B), Read(B), Unlock(B), 
    ... [still holds X-Lock(A)] ... Commit, Unlock(A)

T2: X-Lock(A) [MUST WAIT until T1 commits]
    [No cascading abort: T2 cannot read uncommitted write]
```

**Why cascading aborts are prevented for writes:**
```
T1: X-Lock(A), Write(A=100) ... [T1 aborts, A rolled back]
T2: X-Lock(A) [blocked until T1 finishes]
    [T2 never sees uncommitted value]
```

**Deadlock still possible:**
```
T1: X-Lock(A), ... needs X-Lock(B)
T2: X-Lock(B), ... needs X-Lock(A)
[Deadlock: both hold locks until commit but wait for each other]
```

---

## Rigorous Two-Phase Locking (Rigorous 2PL)

**What it does:**
- Further extends Strict 2PL:
  - **All locks** (both shared and exclusive) must be held until the transaction commits or aborts
- Most restrictive variant of 2PL

**Problem it solves:**
- Prevents all cascading aborts
- Guarantees conflict serializability
- Simplifies recovery maximally
- Provides strongest isolation guarantees among 2PL variants

**Problem it does NOT solve:**
- Does not prevent deadlocks (transactions can still wait for each other's locks in a cycle)

**Example:**
```
T1: S-Lock(A), Read(A), X-Lock(B), Write(B), S-Lock(C), Read(C)
    ... [holds ALL locks] ... Commit, Unlock(A), Unlock(B), Unlock(C)

T2: X-Lock(A) [MUST WAIT until T1 commits - even for read lock]
T3: S-Lock(B) [MUST WAIT until T1 commits - even though T3 only reads]
```

**Why all cascading aborts are prevented:**
```
T1: S-Lock(A), Read(A), X-Lock(B), Write(B) ... [T1 aborts]
T2: S-Lock(A) [blocked - cannot even read the same data T1 read]
    [Maximum isolation: no transaction sees any partial work]
```

**Deadlock still possible:**
```
T1: S-Lock(A), X-Lock(B) [waiting for X-Lock(C)]
T2: S-Lock(C), X-Lock(A) [waiting for X-Lock(A)]
[Deadlock: circular wait even though locks held until commit]
```

---

## Conservative Two-Phase Locking (Conservative 2PL)

**What it does:**
- Requires transactions to acquire **all locks at once** before execution begins
- If any lock cannot be acquired, the transaction releases all locks and waits
- After acquiring all locks, execution proceeds, then all locks are released together

**Problem it solves:**
- **Prevents deadlocks** (since all locks are acquired atomically, circular wait cannot occur)
- Guarantees conflict serializability

**Problem it does NOT solve:**
- Requires knowing all data items needed in advance (often impractical)
- May reduce concurrency (locks held for entire transaction duration)
- Does not inherently prevent cascading aborts unless combined with strict lock holding

**Example:**
```
T1 declares: needs {A, B, C}
T1: [Acquires Lock(A), Lock(B), Lock(C) ALL AT ONCE or waits]
    Read(A), Write(B), Read(C), ... 
    Commit, Unlock(A), Unlock(B), Unlock(C)

T2 declares: needs {C, D}
T2: [Tries to acquire Lock(C), Lock(D)]
    [Lock(C) unavailable because T1 has it]
    [T2 immediately backs off, waits, tries again later]
```

**Why deadlocks are prevented:**
```
T1 needs: {A, B}
T2 needs: {B, C}

Scenario 1:
T1: [Acquires A, B together] → succeeds, executes
T2: [Tries to acquire B, C] → B unavailable, waits

Scenario 2:
T1: [Tries to acquire A, B] → B locked by T2
    [Immediately releases A, waits]
T2: [Already has B, C] → continues

[No circular wait possible: all-or-nothing acquisition]
```

**Why cascading aborts might still occur** [Inference]:
```
Conservative 2PL with early release:
T1: [Lock(A, B) acquired], Write(A=100), Unlock(A), Unlock(B) ... [aborts later]
T2: [Lock(A, C) acquired], Read(A=100) ...
    [T2 may need to abort if T1 aborts]

[Inference]: To prevent this, Conservative 2PL would need to be combined 
with strict holding (hold all locks until commit)
```

---

## Analogy Table

| Variant | Kitchen Analogy | Key Constraint | Deadlock Prevention | Cascading Abort Prevention |
|---------|----------------|----------------|---------------------|---------------------------|
| **Basic 2PL** | Chef gathers ingredients as needed, but once they start putting things away, they can't get more ingredients | Two phases: growing then shrinking | ❌ No | ❌ No |
| **Strict 2PL** | Chef keeps all ingredients they've modified (written to) until the dish is complete | Hold write locks until commit | ❌ No | ✅ Yes (for writes) |
| **Rigorous 2PL** | Chef keeps ALL ingredients (read or modified) until the dish is complete | Hold all locks until commit | ❌ No | ✅ Yes (all) |
| **Conservative 2PL** | Chef gathers ALL ingredients before starting to cook, or waits if any are unavailable | Acquire all locks upfront | ✅ Yes | [Inference] Depends on implementation* |

*[Inference]: Conservative 2PL prevents deadlocks but doesn't inherently specify when locks are released. If implemented to release locks only at commit, it would prevent cascading aborts; if locks can be released earlier, it might not.

---

## Extended Examples: Banking Scenario

### Basic 2PL Example
```
Account A = $1000, Account B = $500

T1 (Transfer $200 from A to B):
  Lock(A), Read(A=1000), A := A-200, Write(A=800)
  Unlock(A)  ← [Shrinking phase begins]
  Lock(B), Read(B=500), B := B+200, Write(B=700), Unlock(B)
  ❌ VIOLATES 2PL: Lock(B) acquired after Unlock(A)

Correct Basic 2PL:
  Lock(A), Lock(B)  ← [Growing phase]
  Read(A=1000), A := A-200, Write(A=800)
  Unlock(A)  ← [Shrinking phase begins]
  Read(B=500), B := B+200, Write(B=700)
  Unlock(B)
  Commit

Problem - Cascading Abort:
T1: Lock(A), Write(A=800), Unlock(A) ... [T1 aborts]
T2: Lock(A), Read(A=800) ... [T2 must abort too]
```

### Strict 2PL Example
```
T1 (Transfer $200 from A to B):
  X-Lock(A), Read(A=1000), Write(A=800)
  X-Lock(B), Read(B=500), Write(B=700)
  [Still holds X-Lock(A) and X-Lock(B)]
  Commit
  Unlock(A), Unlock(B)

T2 (Check total balance):
  S-Lock(A), Read(A) [WAITS until T1 commits]
  S-Lock(B), Read(B)
  
✅ No cascading abort: T2 only sees committed data
❌ Deadlock possible:
  T1: X-Lock(A), [needs X-Lock(B)]
  T2: X-Lock(B), [needs X-Lock(A)]
```

### Rigorous 2PL Example
```
T1 (Transfer $200 from A to B):
  X-Lock(A), Read(A=1000), Write(A=800)
  S-Lock(C), Read(C)  ← [Check some audit log]
  X-Lock(B), Read(B=500), Write(B=700)
  [Holds ALL locks: X-Lock(A), S-Lock(C), X-Lock(B)]
  Commit
  Unlock(A), Unlock(C), Unlock(B)

T2 (Read audit log):
  S-Lock(C) [WAITS even though it's just reading what T1 read]

✅ Maximum isolation
❌ Lower concurrency than Strict 2PL
```

### Conservative 2PL Example
```
T1 declares: needs {A, B, C}
T1: [Attempt to acquire Lock(A), Lock(B), Lock(C)]
    [SUCCESS - all available]
    Read(A=1000), Write(A=800)
    Read(C), Write(B=700)
    Commit, Release all locks

T2 declares: needs {B, D}
T2: [Attempt to acquire Lock(B), Lock(D)]
    [FAILURE - B is locked by T1]
    [Immediately backs off, waits]
    [Retries later after T1 commits]
    [SUCCESS - acquires B and D together]
    Execute...

✅ No deadlock: T2 never holds partial locks while waiting
❌ Requires knowing all data in advance (what if T1 needs to read E based on value in A?)
```

---

## Summary of What Each Solves

- **Basic 2PL**: Serializability only
- **Strict 2PL**: Serializability + prevents cascading aborts from uncommitted writes
- **Rigorous 2PL**: Serializability + prevents all cascading aborts
- **Conservative 2PL**: Serializability + prevents deadlocks

**None of the standard 2PL variants solve both deadlock prevention AND cascading abort prevention simultaneously** in their basic form, though combinations are possible in practice.

---

