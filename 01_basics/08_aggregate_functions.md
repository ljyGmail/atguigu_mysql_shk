# 第08章 聚合函数

> 39 5大常用的聚合函数

## 1. 常见的几个聚合函数

### 1.1 AVG / SUM (只适用于数值类型的字段或变量)

```mysql
SELECT AVG(salary), SUM(salary), AVG(salary) * 107
FROM employees;

# 如下的操作没有意义
SELECT SUM(last_name), AVG(last_name), AVG(hire_date)
FROM employees; # -> 0, 0 , xxx
```

### 1.2 MAX / MIN (适用于数值类型、字符串类型、日期时间类型的字段或变量)

```mysql
SELECT MAX(salary), MIN(salary)
FROM employees;

SELECT MAX(last_name), MIN(last_name), MAX(hire_date), MIN(hire_date)
FROM employees;
```

### 1.3 COUNT

```mysql
# 1️⃣作用: 计算指定字段在查询结果中出现的个数 (不包含NULL值)
SELECT COUNT(employee_id), COUNT(salary), COUNT(2 * salary), COUNT(1), COUNT(2), COUNT(*)
FROM employees;

SELECT *
FROM employees;

# 如果计算表中有多少条记录，如何实现?
# 方式1: COUNT(*)
# 方式2: COUNT(1)
# 方式3: COUNT(具体字段) -> 不一定对!

# 2️⃣注意: 计算指定字段出现的个数时，是不计算NULL值的。
SELECT COUNT(commission_pct)
FROM employees;

SELECT commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;

# 3️⃣公式: AVG = SUM / COUNT
SELECT AVG(salary),
       SUM(salary) / COUNT(salary),
       AVG(commission_pct),
       SUM(commission_pct) / COUNT(commission_pct),
       SUM(commission_pct) / 107
FROM employees;

# 需求: 查询公司中平均奖金率。
# 错误的:
SELECT AVG(commission_pct)
FROM employees;

# 正确的:
SELECT SUM(commission_pct) / COUNT(IFNULL(commission_pct, 0)),
       AVG(IFNULL(commission_pct, 0))
FROM employees

# 如果需要统计表中的记录数，使用COUNT(*)、COUNT(1)、COUNT(具体字段) 那个效率更高呢?
# 如果使用的是MyISAM存储引擎，则三者效率相同，都是O(1)。
# 如果使用的是InnoDB存储引擎，则COUNT(*) = COUNT(1) > COUNT(具体字段)。
```

### 1.4 其它: 方差、标准差、中位数

## 2. GROUP BY的使用

```mysql
# 需求: 查询各个部门的平局工资、最高工资。
SELECT department_id, AVG(salary), MAX(salary)
FROM employees
GROUP BY department_id;

# 需求: 查询各个job_id的平均工资。
SELECT job_id, AVG(salary)
FROM employees
GROUP BY job_id;

# 需求: 查询各个department_id，job_id的平均工资。
# 方式1:
SELECT department_id, job_id, AVG(salary)
FROM employees
GROUP BY department_id, job_id;

# 方式2:
SELECT job_id, department_id, AVG(salary)
FROM employees
GROUP BY job_id, department_id;

# 错误的!
SELECT department_id, job_id, AVG(salary)
FROM employees
GROUP BY department_id;

# 结论1: SELECT中出现的非组函数的字段必须声明在GROUP BY中。
#      反之，GROUP BY中声明的字段可以不出现在SELECT中。

# 结论2: GROUP BY声明在FROM后面、WHERE后面，ORDER BY前面、LIMIT前面。

# 结论3: MySQL中GROUP BY中使用WITH ROLLUP。
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
WITH ROLLUP;

# 说明: 需要注意同时使用WITH ROLLUP和ORDER BY，可能会得到错误的结果!
SELECT department_id, AVG(salary) avg_sal
FROM employees
GROUP BY department_id
WITH ROLLUP
ORDER BY avg_sal ASC;
```

## 3. HAVING的使用

## 4. SQL底层执行原理

