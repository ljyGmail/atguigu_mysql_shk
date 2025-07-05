# 第06章 多表查询

> 25 为什么需要多表的查询

```text
SELECT ..., ..., ...
FROM ...
WHERE ... AND / OR / NOT ...
ORDER ... (ASC/DESC), ..., ...
LIMIT ..., ...
```

```mysql
# 1. 熟悉常见的几个表
DESC employees;
DESC departments;
DESC locations;

# 练习: 查询员工名为'Abel'的人在哪个城市工作?
SELECT *
FROM employees
WHERE last_name = 'Abel'; # department_id = 80

SELECT *
FROM departments
WHERE department_id = 80; # location_id = 2500

SELECT *
FROM locations
WHERE location_id = 2500;
```