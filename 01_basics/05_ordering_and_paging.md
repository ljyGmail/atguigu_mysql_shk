# 第05章 排序与分页

> 22 ORDER BY实现排序操作

## 1. 排序

```mysql
# 1. 基本使用

# 如果没有使用排序操作，默认情况下查询返回的数据是按照添加数据的顺序显示的。
SELECT *
FROM employees;

# 使用ORDER BY对查询的数据进行排序操作。
# 升序: ASC (ascending)
# 降序: DESC (descending)

# 练习: 按照salary从高到低的顺序显示员工信息。
SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary DESC;

# 练习: 按照salary从低到高的顺序显示员工信息。
SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary ASC;

SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary;
# 如果在ORDER BY后没有显式指明排序的方式，则默认按照升序排列。

# 2. 可以使用列的别名进行排序。
SELECT employee_id, salary, salary * 12 annual_sal
FROM employees
ORDER BY annual_sal;

# 列的别名只能在ORDER BY中使用，不能在WHERE中使用。
# 如下操作报错!
# SELECT employee_id, salary, salary * 12 annual_sal
# FROM employees
# WHERE annual_sal > 81600;

# 3. 强调格式: WHERE需要声明在FROM之后，ORDER BY之前。
SELECT employee_id, salary
FROM employees
WHERE department_id IN (50, 60, 70)
ORDER BY department_id DESC;

# 4. 二级排序
# 练习: 显示员工信息，按照department_id的降序排列，salary的升序排列。
SELECT employee_id, salary, department_id
FROM employees
ORDER BY department_id DESC, salary ASC;
```

## 2. 分页

### 2.1 MySQL使用LIMIT实现数据的分页显示

```mysql
# 需求1: 每页显示20条记录，此时显示第1页
SELECT employee_id, last_name
FROM employees
LIMIT 0, 20;

# 需求2: 每页显示20条记录，此时显示第2页
SELECT employee_id, last_name
FROM employees
LIMIT 20, 20;

# 需求3: 每页显示20条记录，此时显示第3页
SELECT employee_id, last_name
FROM employees
LIMIT 40, 20;

# 需求3: 每页显示pageSize条记录，此时显示第pageNo页
# 公式: LIMIT (pageNo - 1) * pageSize, pageSize
```

### 2.2 WHERE ... ORDER BY ... LIMIT的声明顺序如下:

```mysql
# LIMIT的格式: 严格来说，LIMIT 位置偏移量,条目数
# 结构 "LIMIT 0,条目数"等价于"LIMIT 条目数"
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > 6000
ORDER BY salary DESC
# LIMIT 0, 10;
LIMIT 10;

# 练习: 表里有107条数据，我们只想要显示第32、33条数据怎么办?
SELECT employee_id, last_name
FROM employees
LIMIT 31,2;
```

### 2.3 MySQL8.0新特性: LIMIT ... OFFSET ...

```mysql
SELECT employee_id, last_name
FROM employees
LIMIT 2 OFFSET 31;

# 练习: 查询员工表中工资最高的员工信息。
SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary DESC
# LIMIT 0, 1;
LIMIT 1;
```

### 2.4 拓展: LIMIT可以使用在MySQL、PGSQL、MariaDB、SQLite等数据库中使用，表示分页。不能使用在SQL Server、DB2、Oracle!

> 24 第五章 排序与分页 课后练习

## 课后练习

```mysql
# 1. 查询员工的姓名和部门号和年薪，按年薪降序,按姓名升序显示
SELECT last_name, department_id, salary * 12 annual_salary
FROM employees
ORDER BY annual_salary DESC, last_name ASC;

# 2. 选择工资不在 8000 到 17000 的员工的姓名和工资，按工资降序，显示第21到40位置的数据
SELECT last_name, salary
FROM employees
WHERE salary NOT BETWEEN 8000 AND 17000
ORDER BY salary DESC
LIMIT 20,20;

# 3. 查询邮箱中包含 e 的员工信息，并先按邮箱的字节数降序，再按部门号升序
SELECT employee_id, last_name, email, department_id
FROM employees
# WHERE email LIKE '%e%'
WHERE email REGEXP '[e]'
ORDER BY LENGTH(email) DESC, department_id ASC;
```
