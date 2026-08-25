## Window Functions in PostgreSQL


### Introduction to Window Functions

Window functions are a powerful feature in PostgreSQL that perform calculations across a set of table rows related to the current row. Unlike regular aggregate functions which group rows into a single output row, window functions retain all rows in the result set. This allows you to add calculated fields based on values in related rows while keeping the detail-level data.

**Key Points:**

- Window functions process rows that are somehow related to the current row
- They don't collapse groups of rows to a single output row like GROUP BY does
- They allow access to more than just the current row of the query result
- Introduced in PostgreSQL 8.4 (2009) with significant enhancements in later versions

### Window Function Syntax

Window functions use a special OVER clause which defines the "window" of rows to be considered for each calculation.

```sql
function_name(expression) OVER (
    [PARTITION BY column1, column2, ...]
    [ORDER BY column3, column4, ...]
    [frame_clause]
)
```

### Components of Window Functions

#### PARTITION BY Clause

PARTITION BY divides the result set into partitions (groups) to which the window function is applied separately.

```sql
SELECT 
    department,
    employee_name,
    salary,
    AVG(salary) OVER (PARTITION BY department) as avg_department_salary
FROM employees;
```

#### ORDER BY Clause

ORDER BY determines the order of rows within each partition for functions that are sensitive to row order.

```sql
SELECT 
    employee_name,
    hire_date,
    department,
    RANK() OVER (PARTITION BY department ORDER BY hire_date) as seniority_rank
FROM employees;
```

#### Frame Clause

The frame clause further refines which rows within the partition are included in the window function calculation.

```sql
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as rolling_3day_revenue
FROM daily_sales;
```

Common frame specifications include:

- `ROWS BETWEEN n PRECEDING AND CURRENT ROW`
- `ROWS BETWEEN CURRENT ROW AND n FOLLOWING`
- `ROWS BETWEEN n PRECEDING AND n FOLLOWING`
- `RANGE BETWEEN interval AND interval`

### Common Window Functions

#### Ranking Functions

**RANK()** Returns the rank of the current row with gaps.

```sql
SELECT 
    product_name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
FROM products;
```

**DENSE_RANK()** Returns rank without gaps.

```sql
SELECT 
    student_name,
    score,
    DENSE_RANK() OVER (ORDER BY score DESC) as position
FROM exam_results;
```

**ROW_NUMBER()** Returns a unique sequential number.

```sql
SELECT 
    order_id,
    order_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as customer_order_sequence
FROM orders;
```

**NTILE(n)** Divides rows into n equal groups.

```sql
SELECT 
    product_name,
    price,
    NTILE(4) OVER (ORDER BY price) as price_quartile
FROM products;
```

#### Offset Functions

**LAG()** Accesses data from previous rows.

```sql
SELECT 
    date,
    stock_price,
    LAG(stock_price, 1) OVER (ORDER BY date) as previous_day_price,
    stock_price - LAG(stock_price, 1) OVER (ORDER BY date) as price_change
FROM stock_history;
```

**LEAD()** Accesses data from subsequent rows.

```sql
SELECT 
    date,
    sales,
    LEAD(sales, 1) OVER (ORDER BY date) as next_day_sales
FROM daily_sales;
```

**FIRST_VALUE() and LAST_VALUE()** Return first or last value in an ordered set.

```sql
SELECT 
    month,
    revenue,
    FIRST_VALUE(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as first_month_revenue,
    LAST_VALUE(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_month_revenue
FROM monthly_revenue;
```

#### Aggregate Window Functions

Any aggregate function (SUM, AVG, MIN, MAX, COUNT) can be used as a window function.

```sql
SELECT 
    employee_name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department) as department_total_salary,
    salary / SUM(salary) OVER (PARTITION BY department) * 100 as percentage_of_dept_salary
FROM employees;
```

### Advanced Window Function Techniques

#### Multiple Window Functions in One Query

```sql
SELECT 
    product_name,
    category,
    price,
    RANK() OVER w as price_rank,
    DENSE_RANK() OVER w as dense_price_rank,
    ROW_NUMBER() OVER w as row_num
FROM products
WINDOW w AS (PARTITION BY category ORDER BY price DESC);
```

#### Cumulative Distributions

**PERCENT_RANK()** Returns relative rank as a percentage.

```sql
SELECT 
    product_name,
    price,
    PERCENT_RANK() OVER (ORDER BY price) as percentile
FROM products;
```

**CUME_DIST()** Returns cumulative distribution.

```sql
SELECT 
    product_name,
    price,
    CUME_DIST() OVER (ORDER BY price) as cumulative_distribution
FROM products;
```

#### Handling Ties with RANK Variations

**Example:**

```sql
SELECT 
    student_name,
    score,
    RANK() OVER (ORDER BY score DESC) as rank,
    DENSE_RANK() OVER (ORDER BY score DESC) as dense_rank,
    ROW_NUMBER() OVER (ORDER BY score DESC) as row_num
FROM exam_results;
```

**Output:**

```
 student_name | score | rank | dense_rank | row_num
--------------+-------+------+------------+---------
 Alice        |   95  |   1  |     1      |    1
 Bob          |   95  |   1  |     1      |    2
 Charlie      |   90  |   3  |     2      |    3
 David        |   85  |   4  |     3      |    4
```

### Performance Considerations

- Window functions are typically processed after WHERE, GROUP BY, and HAVING clauses
- They can be resource-intensive for large datasets
- Consider indexing columns used in PARTITION BY and ORDER BY clauses
- Use window functions to replace complex self-joins for better performance
- CTEs (Common Table Expressions) can help organize complex window function queries

### Common Use Cases

#### Running Totals and Moving Averages

```sql
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) as running_total,
    AVG(revenue) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as weekly_moving_avg
FROM daily_sales;
```

#### Time Series Analysis

```sql
SELECT 
    date,
    value,
    LAG(value) OVER (ORDER BY date) as previous_value,
    (value - LAG(value) OVER (ORDER BY date)) / LAG(value) OVER (ORDER BY date) * 100 as percent_change
FROM time_series_data;
```

#### Top N Records per Group

```sql
WITH ranked_products AS (
    SELECT 
        category,
        product_name,
        price,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
    FROM products
)
SELECT * FROM ranked_products WHERE price_rank <= 3;
```

#### Calculating Percentiles

```sql
SELECT 
    employee_name,
    department,
    salary,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary) * 100 as salary_percentile
FROM employees;
```

### Window Functions vs. GROUP BY

While both GROUP BY and window functions perform calculations across multiple rows, they serve different purposes:

|GROUP BY|Window Functions|
|---|---|
|Collapses rows into summary rows|Preserves all original rows|
|One output row per group|One output row for each input row|
|Cannot mix detail and aggregated data|Can show both detail and calculated data|
|Used for reporting and summarizing|Used for analytical calculations|

**Example:**

```sql
-- Using GROUP BY (loses detail)
SELECT 
    department,
    AVG(salary) as avg_salary
FROM employees
GROUP BY department;

-- Using window function (preserves detail)
SELECT 
    employee_name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as avg_department_salary
FROM employees;
```

### PostgreSQL-Specific Window Features

#### Ordered-Set Aggregate Functions

PostgreSQL allows certain aggregate functions to use an ORDER BY clause within the function itself.

```sql
SELECT 
    department,
    mode() WITHIN GROUP (ORDER BY salary) as most_common_salary,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY salary) as median_salary
FROM employees
GROUP BY department;
```

#### FILTER Clause

The FILTER clause allows conditional aggregation.

```sql
SELECT 
    department,
    COUNT(*) as total_employees,
    COUNT(*) FILTER (WHERE salary > 50000) as high_paid_employees
FROM employees
GROUP BY department;
```

### Troubleshooting Window Functions

#### Common Issues

- Frame clause misspecification
- Unexpected NULL handling
- Order dependencies in calculations
- Performance problems with large datasets

#### Best Practices

- Start simple and build complexity
- Test with smaller datasets first
- Use CTEs to break down complex window function queries
- Be explicit about frame specifications
- Verify calculations match expected results

### Recommended related topics:

- Common Table Expressions (CTEs) in PostgreSQL
- Advanced aggregation techniques in PostgreSQL
- PostgreSQL materialized views for storing window function results
- Indexing strategies for optimizing window function performance
- PostgreSQL partitioning for large datasets requiring window functions

---

