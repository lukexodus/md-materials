## Working with Views and Materialized Views


### Introduction to Database Views

Database views are virtual tables defined by SQL queries that present data as if the data were coming from a regular table. Views do not store data themselves but provide a way to look at data stored in other tables. They serve as a powerful abstraction layer that can simplify complex queries, enforce security, and provide data independence.

### Basic View Concepts

Views are essentially stored queries that can be referenced like tables in SQL statements. When you query a view, the database engine processes the view's underlying query and returns the results. This provides a level of abstraction that separates the application from the physical database structure.

```sql
CREATE VIEW customer_orders_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
```

### Benefits of Regular Views

**Key Points:**

- **Simplification** - Hide complex joins and calculations behind a simple interface
- **Security** - Restrict access to specific columns or rows of underlying tables
- **Data independence** - Shield applications from structural changes in the database
- **Query reuse** - Define complex logic once and reuse across multiple queries
- **Reduced complexity** - Break down complex queries into manageable components
- **Consistency** - Ensure consistent business logic across applications

### Types of Views

#### Simple Views

Single table views with basic selections and filters.

```sql
CREATE VIEW active_users AS
SELECT user_id, username, email
FROM users
WHERE status = 'active';
```

#### Complex Views

Multi-table views involving joins, calculations, and aggregations.

```sql
CREATE VIEW product_sales_analysis AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(s.quantity) AS units_sold,
    SUM(s.quantity * p.price) AS revenue
FROM products p
JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category;
```

#### Updatable Views

Views that allow INSERT, UPDATE, and DELETE operations to be performed through them, affecting the underlying base tables.

```sql
CREATE VIEW current_employees AS
SELECT employee_id, first_name, last_name, department, salary
FROM employees
WHERE termination_date IS NULL;
```

#### Read-Only Views

Views that cannot be updated directly due to complexity or by explicit declaration.

```sql
CREATE VIEW quarterly_sales AS
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(QUARTER FROM sale_date) AS quarter,
    SUM(amount) AS total_sales
FROM sales
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(QUARTER FROM sale_date);
```

### View Operations

#### Creating Views

```sql
CREATE [OR REPLACE] VIEW view_name [(column_list)]
AS select_statement
[WITH CHECK OPTION];
```

The `WITH CHECK OPTION` ensures that any data modifications made through the view conform to the view's defining query.

#### Altering Views

```sql
ALTER VIEW view_name
AS new_select_statement;
```

#### Dropping Views

```sql
DROP VIEW [IF EXISTS] view_name;
```

#### Querying Views

```sql
SELECT * FROM view_name WHERE condition;
```

### View Limitations and Considerations

- Performance overhead for complex view definitions
- Some views cannot be directly updated (those with aggregations, DISTINCT, GROUP BY, etc.)
- Views are recomputed on each access (unless optimized by the DBMS)
- Dependency management can be challenging
- Some databases limit the nesting depth of views

### Introduction to Materialized Views

Unlike regular views, materialized views physically store the query results as a table. They are pre-computed result sets that can be refreshed periodically or on-demand, offering significant performance benefits for complex queries or frequently accessed data.

### Materialized View Concepts

```sql
CREATE MATERIALIZED VIEW mv_monthly_sales
AS
SELECT 
    product_category,
    DATE_TRUNC('month', sale_date) AS month,
    SUM(amount) AS monthly_sales
FROM sales
JOIN products ON sales.product_id = products.id
GROUP BY product_category, DATE_TRUNC('month', sale_date);
```

### Key Differences: Views vs. Materialized Views

**Key Points:**

- **Storage**: Regular views don't store data; materialized views store physical result sets
- **Query performance**: Materialized views offer faster access but require refresh operations
- **Data freshness**: Regular views always show current data; materialized views may contain stale data
- **Maintenance**: Materialized views require refresh strategies; regular views need no maintenance
- **Resource usage**: Materialized views use disk space; regular views use minimal storage
- **Best use cases**: Materialized views for performance-critical reporting; regular views for data abstraction

### Benefits of Materialized Views

- Dramatically improved query performance for complex calculations
- Reduced load on database servers for reporting queries
- Ability to create indexes on materialized view columns
- Support for distributed databases and replication
- Ideal for data warehousing and business intelligence applications

### Materialized View Operations

#### Creating Materialized Views

```sql
-- PostgreSQL syntax
CREATE MATERIALIZED VIEW mv_name
AS query
[WITH [NO] DATA];

-- Oracle syntax
CREATE MATERIALIZED VIEW mv_name
BUILD [IMMEDIATE | DEFERRED]
REFRESH [FAST | COMPLETE | FORCE] ON [COMMIT | DEMAND]
AS query;
```

#### Refreshing Materialized Views

```sql
-- PostgreSQL
REFRESH MATERIALIZED VIEW [CONCURRENTLY] mv_name;

-- Oracle
BEGIN
  DBMS_MVIEW.REFRESH('mv_name', 'C'); -- Complete refresh
END;
```

#### Indexing Materialized Views

```sql
CREATE INDEX idx_mv_monthly_sales_category 
ON mv_monthly_sales(product_category);
```

### Refresh Strategies for Materialized Views

#### Complete Refresh

Rebuilds the entire materialized view from scratch.

```sql
REFRESH MATERIALIZED VIEW mv_name;
```

#### Incremental Refresh

Updates only the changed data (available in some DBMS like Oracle).

```sql
-- Oracle syntax
CREATE MATERIALIZED VIEW mv_name
REFRESH FAST ON COMMIT
AS query;
```

#### On-Demand Refresh

Manually refreshed when needed.

```sql
REFRESH MATERIALIZED VIEW mv_name;
```

#### Scheduled Refresh

Automated refresh through database scheduler jobs.

```sql
-- PostgreSQL using pg_cron extension
SELECT cron.schedule('0 2 * * *', 'REFRESH MATERIALIZED VIEW mv_name');
```

### Database Support and Variations

#### PostgreSQL

Offers robust materialized view support with concurrent refresh capabilities.

```sql
CREATE MATERIALIZED VIEW mv_name AS query;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_name;
```

#### Oracle

Provides advanced materialized view features including query rewrite and multiple refresh methods.

```sql
CREATE MATERIALIZED VIEW mv_name
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS query;
```

#### SQL Server

Uses indexed views which are similar to materialized views.

```sql
CREATE VIEW view_name WITH SCHEMABINDING AS query;
CREATE UNIQUE CLUSTERED INDEX idx_view ON view_name(column);
```

#### MySQL

Prior to MySQL 8.0, materialized views were not directly supported but could be simulated with tables and triggers.

### Practical Use Cases

#### Data Warehousing and OLAP

**Example:**

```sql
CREATE MATERIALIZED VIEW mv_sales_dimensions AS
SELECT 
    p.category,
    p.subcategory,
    c.region,
    c.country,
    t.year,
    t.quarter,
    t.month,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.customer_id) AS customer_count
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_customer c ON f.customer_id = c.customer_id
JOIN dim_time t ON f.time_id = t.time_id
GROUP BY p.category, p.subcategory, c.region, c.country, t.year, t.quarter, t.month;
```

#### Reporting Dashboards

```sql
CREATE MATERIALIZED VIEW mv_daily_stats AS
SELECT 
    DATE_TRUNC('day', event_timestamp) AS day,
    event_type,
    COUNT(*) AS event_count,
    COUNT(DISTINCT user_id) AS unique_users
FROM user_events
GROUP BY DATE_TRUNC('day', event_timestamp), event_type;
```

#### API Response Caching

```sql
CREATE MATERIALIZED VIEW mv_product_details AS
SELECT 
    p.product_id,
    p.name,
    p.description,
    p.price,
    c.category_name,
    m.manufacturer_name,
    ARRAY_AGG(t.tag_name) AS tags,
    AVG(r.rating) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN manufacturers m ON p.manufacturer_id = m.manufacturer_id
LEFT JOIN product_tags pt ON p.product_id = pt.product_id
LEFT JOIN tags t ON pt.tag_id = t.tag_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, p.description, p.price, c.category_name, m.manufacturer_name;
```

### Performance Optimization Techniques

#### Strategic Indexing

```sql
CREATE INDEX idx_mv_sales_region_year ON mv_sales_dimensions(region, year);
```

#### Partial Materialized Views

```sql
-- PostgreSQL
CREATE MATERIALIZED VIEW mv_premium_customers AS
SELECT customer_id, name, email, total_spent
FROM customer_purchase_summary
WHERE customer_tier = 'premium';
```

#### Join Materialization

```sql
CREATE MATERIALIZED VIEW mv_order_details AS
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    c.customer_email,
    p.product_name,
    p.product_category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
```

### Monitoring and Maintenance

#### View Dependencies

```sql
-- PostgreSQL
SELECT * FROM pg_depend
WHERE refobjid = 'view_name'::regclass::oid;

-- Oracle
SELECT * FROM ALL_DEPENDENCIES
WHERE NAME = 'VIEW_NAME' AND TYPE = 'VIEW';
```

#### Refresh History

```sql
-- Oracle
SELECT * FROM dba_mview_refresh_times
WHERE name = 'MV_NAME';
```

#### Size and Usage Statistics

```sql
-- PostgreSQL
SELECT 
    relname AS materialized_view,
    pg_size_pretty(pg_total_relation_size(oid)) AS total_size
FROM pg_class
WHERE relkind = 'm';
```

### Advanced Topics

#### Nested Views

Views that reference other views in their definition.

```sql
CREATE VIEW sales_by_category AS
SELECT category, SUM(sales_amount) AS total_sales
FROM product_sales_view
GROUP BY category;
```

#### Materialized View Logs

Oracle-specific feature that tracks changes to base tables for fast refreshes.

```sql
-- Oracle syntax
CREATE MATERIALIZED VIEW LOG ON base_table
WITH ROWID, PRIMARY KEY, SEQUENCE
INCLUDING NEW VALUES;
```

#### Query Rewrite

Optimization where the database automatically uses materialized views when applicable.

```sql
-- Oracle syntax
CREATE MATERIALIZED VIEW mv_name
ENABLE QUERY REWRITE
AS query;
```

#### Incremental Statistics Maintenance

```sql
-- Oracle
EXECUTE DBMS_STATS.GATHER_TABLE_STATS('SCHEMA', 'MV_NAME');
```

### Best Practices

**Key Points:**

- Create materialized views for frequently executed complex queries
- Use regular views for security, abstraction, and query simplification
- Carefully plan refresh strategies based on data volatility and query patterns
- Consider storage requirements and maintenance windows
- Create appropriate indexes on materialized views
- Document view dependencies for easier schema maintenance
- Monitor view usage and performance to optimize refresh schedules
- Use partitioning for large materialized views where supported

### Example: E-commerce Analytics Pipeline

**Example:**

Building a comprehensive analytics system with views and materialized views:

```sql
-- Base views for data access and security
CREATE VIEW vw_customer_data AS
SELECT customer_id, name, email, city, state, customer_since
FROM customers
WHERE status = 'active';

CREATE VIEW vw_order_details AS
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_date, 
    o.status,
    oi.product_id, 
    oi.quantity, 
    oi.unit_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- Materialized aggregation for reporting
CREATE MATERIALIZED VIEW mv_daily_sales_summary AS
SELECT 
    DATE_TRUNC('day', o.order_date) AS day,
    p.category,
    COUNT(DISTINCT o.order_id) AS num_orders,
    COUNT(DISTINCT o.customer_id) AS num_customers,
    SUM(oi.quantity) AS total_units,
    SUM(oi.quantity * oi.unit_price) AS gross_revenue
FROM vw_order_details oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status != 'cancelled'
GROUP BY DATE_TRUNC('day', o.order_date), p.category;

-- Materialized customer analytics
CREATE MATERIALIZED VIEW mv_customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.name,
    c.email,
    c.customer_since,
    COUNT(DISTINCT o.order_id) AS lifetime_orders,
    SUM(oi.quantity * oi.unit_price) AS lifetime_spend,
    AVG(oi.quantity * oi.unit_price) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    EXTRACT(DAY FROM NOW() - MAX(o.order_date)) AS days_since_last_order
FROM vw_customer_data c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name, c.email, c.customer_since;

-- Index for performance
CREATE INDEX idx_mv_daily_sales_day ON mv_daily_sales_summary(day);
CREATE INDEX idx_mv_daily_sales_category ON mv_daily_sales_summary(category);
CREATE INDEX idx_mv_clv_spend ON mv_customer_lifetime_value(lifetime_spend DESC);
```

**Output:**

```
-- Sample query using the views
SELECT 
    category,
    SUM(gross_revenue) AS monthly_revenue,
    SUM(num_orders) AS monthly_orders,
    SUM(num_customers) AS monthly_customers
FROM mv_daily_sales_summary
WHERE day BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY category
ORDER BY monthly_revenue DESC;

| category      | monthly_revenue | monthly_orders | monthly_customers |
|---------------|----------------|---------------|------------------|
| Electronics   | 128,450.00     | 1,245         | 987              |
| Home & Garden | 87,325.50      | 2,341         | 1,876            |
| Clothing      | 76,543.25      | 3,452         | 2,354            |
| Sporting Goods| 43,210.75      | 876           | 721              |
| Books         | 21,654.50      | 1,543         | 1,324            |
```

**Conclusion**

**Conclusion:** Views and materialized views are essential components of modern database systems that provide powerful abstraction, security, and performance benefits. Regular views offer logical data organization and access control without storage overhead, while materialized views deliver significant performance improvements at the cost of some data freshness and maintenance requirements. By strategically combining both approaches, database architects can build scalable, maintainable systems that balance performance needs with resource constraints, leading to more efficient applications and better user experiences.

### Related Topics

- Partitioned views and materialized views
- View indexing strategies
- Automated materialized view refresh mechanisms
- View dependency management
- Materialized view query optimization
- View-based access control
- Distributed materialized views
- View metadata management and documentation

---

