# 第15章 存储过程与函数

> 78 存储过程使用说明

> 79 存储过程的创建与调用

## 0. 准备工作

```mysql
CREATE DATABASE IF NOT EXISTS dbtest15;

USE dbtest15;

CREATE TABLE employees
AS
SELECT *
FROM atguigudb.employees;

CREATE TABLE departments
AS
SELECT *
FROM atguigudb.departments;

SELECT *
FROM employees;

SELECT *
FROM departments;
```

## 1. 创建存储过程

```mysql
# 类型1: 无参数 无返回值
# 举例1: 创建存储过程select_all_data()，查看employees表的所有数据。
DELIMITER $

CREATE PROCEDURE IF NOT EXISTS select_all_data()
BEGIN
    SELECT * FROM employees;
END;

DELIMITER ;
```

## 2. 存储过程的调用

```mysql
CALL select_all_data();

# 举例2: 创建存储过程avg_employee_salary()，返回所有员工的平均工资。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS avg_employee_salary()
BEGIN
    SELECT AVG(salary)
    FROM employees end;
END;

DELIMITER //

# 调用
CALL avg_employee_salary();

# 举例3: 创建存储过程show_max_salary()，用来查看employees表的最高薪资值。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS show_max_salary()
BEGIN
    SELECT MAX(salary)
    FROM employees;
END //

DELIMITER ;

# 调用
CALL show_max_salary();

# 类型2: 带 OUT
# 举例4：创建存储过程show_min_salary()，查看employees表的最低薪资值。并将最低薪资通过OUT参数“ms”输出。
DESC employees;

DELIMITER //

CREATE PROCEDURE show_min_salary(OUT ms DOUBLE)
BEGIN
    SELECT MIN(salary) INTO ms FROM employees;
END //

DELIMITER ;

# 调用
CALL show_min_salary(@ms);

# 查看变量值
SELECT @ms;

# 类型3: 带 IN
# 举例5：创建存储过程show_someone_salary()，查看employees表的某个员工的薪资，并用IN参数empname输入员工姓名。
DELIMITER //

CREATE PROCEDURE show_someone_salary(IN empname VARCHAR(20))
BEGIN
    SELECT salary
    FROM employees
    WHERE last_name = empname;
END //

DELIMITER ;

# 调用方式1:
CALL show_someone_salary('Abel');

# 调用方式2:
SET @empname := 'Abel';
CALL show_someone_salary(@empname);

SELECT *
FROM employees
WHERE last_name = 'Abel';

# 类型4: 带IN和OUT
# 举例6：创建存储过程show_someone_salary2()，查看“emps”表的某个员工的薪资，并用IN参数empname
# 输入员工姓名，用OUT参数empsalary输出员工薪资。

DELIMITER //

CREATE PROCEDURE show_someone_salary2(IN empname VARCHAR(20), OUT empsalary DECIMAL(10, 2))
BEGIN
    SELECT salary INTO empsalary FROM employees WHERE last_name = empname;
END //

DELIMITER ;

# 调用
SET @empname = 'Abel';
CALL show_someone_salary2(@empname, @empsalary);

SELECT @empsalary;

# 类型5: 带INOUT
# 举例7：创建存储过程show_mgr_name()，查询某个员工领导的姓名，并用INOUT参数“empname”输入员工姓名，输出领导的姓名。
DESC employees;

DELIMITER $

CREATE PROCEDURE show_mgr_name(INOUT empname VARCHAR(25))
BEGIN
    SELECT last_name
    INTO empname
    FROM employees
    WHERE employee_id = (SELECT manager_id
                         FROM employees
                         WHERE last_name = empname);
END $

DELIMITER ;

# 调用
SET @empname := 'Abel';
CALL show_mgr_name(@empname);

SELECT @empname;
```



