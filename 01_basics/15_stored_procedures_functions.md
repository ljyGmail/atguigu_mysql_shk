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

> 80 存储函数的创建与调用

## 2. 存储函数

```mysql
# 举例1: 创建存储函数，名称为email_by_name()，参数定义为空，该函数查询Abel的email，并返回，数据类型为字符串类型。
DELIMITER //

CREATE FUNCTION email_by_name()
    RETURNS VARCHAR(25)
    DETERMINISTIC
    CONTAINS SQL
    READS SQL DATA
BEGIN
    RETURN (SELECT email FROM employees WHERE last_name = 'Abel');
END //

DELIMITER ;

# 调用
SELECT email_by_name();

SELECT email, last_name
FROM employees
WHERE last_name = 'Abel';

# 举例2: 创建存储函数，名称为email_by_id()，参数传入emp_id，该函数查询emp_id的email，并返回，数据类型为字符串类型。

# 创建函数前执行此语句，保证函数的创建会成功。
SET GLOBAL LOG_BIN_TRUST_FUNCTION_CREATORS = 1;

DELIMITER //

CREATE FUNCTION email_by_id(emp_id INT)
    RETURNS VARCHAR(25)
BEGIN
    RETURN (SELECT email FROM employees WHERE employee_id = emp_id);
END //

DELIMITER ;

# 调用
SELECT email_by_id(100);

SET @emp_id = 102;
SELECT email_by_id(@emp_id);


# 举例3: 创建存储函数，名称为count_by_id()，参数传入dept_id，该函数查询dept_id部门的员工人数，并返回，数据类型为整形。
DELIMITER //

CREATE FUNCTION count_by_id(dept_id INT)
    RETURNS INT
BEGIN
    RETURN (SELECT COUNT(*) FROM employees WHERE department_id = dept_id);
END //

DELIMITER ;

# 调用
SET @dept_id := 50;
SELECT count_by_id(@dept_id);
```

> 81 存储过程与函数的查看、修改和删除

## 3. 存储过程与函数的查看

### 3.1 使用SHOW CREATE语句查看存储过程和函数的创建信息

```mysql
SHOW CREATE PROCEDURE show_mgr_name;

SHOW CREATE FUNCTION count_by_id;
```

### 3.2 使用SHOW STATUS语句查看存储过程和函数的状态信息

```mysql
SHOW PROCEDURE STATUS;

SHOW PROCEDURE STATUS LIKE 'show_max_salary';

SHOW FUNCTION STATUS LIKE 'email_by_id';
```

### 3.3 从information_schema.Routines表中查看存储过程和函数的信息

```mysql
SELECT *
FROM information_schema.ROUTINES
WHERE ROUTINE_NAME = 'email_by_id'
  AND ROUTINE_TYPE = 'FUNCTION'; # 此处区分大小写

SELECT *
FROM information_schema.ROUTINES
WHERE ROUTINE_NAME = 'show_min_salary'
  AND ROUTINE_TYPE = 'PROCEDURE'; # 此处区分大小写
```

## 4. 存储过程与函数的修改

```mysql
# 只能修改存储过程或存储函数的一些特性信息，无法修改函数体。若要修改函数体，就先删除后再重新创建。
ALTER PROCEDURE show_max_salary
    SQL SECURITY INVOKER
    COMMENT '查询最高工资';
```

## 5. 存储过程与函数的删除

```mysql
DROP FUNCTION IF EXISTS count_by_id;

DROP PROCEDURE IF EXISTS show_min_salary;
```

> 82 第15章 存储过程函数 课后练习

## 课后练习

```mysql
# 存储过程的练习
# 0. 准备工作
CREATE DATABASE IF NOT EXISTS test15_pro_func;

USE test15_pro_func;

# 1. 创建存储过程insert_user(),实现传入用户名和密码，插入到admin表中
CREATE TABLE admin
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(15) NOT NULL,
    pwd       VARCHAR(25) NOT NULL
);

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS insert_user(IN user_name VARCHAR(15), IN pwd VARCHAR(25))
BEGIN
    INSERT INTO admin(user_name, pwd) VALUES (user_name, pwd);
END //

DELIMITER ;

# 调用
SET @user_name := 'ljy';
SET @pwd := '123456';
CALL insert_user(@user_name, @pwd);

SELECT *
FROM admin;

# 2. 创建存储过程get_phone(),实现传入女神编号，返回女神姓名和女神电话
CREATE TABLE beauty
(
    id    INT PRIMARY KEY AUTO_INCREMENT,
    NAME  VARCHAR(15) NOT NULL,
    phone VARCHAR(15) UNIQUE,
    birth DATE
);

INSERT INTO beauty(NAME, phone, birth)
VALUES ('朱茵', '13201233453', '1982-02-12'),
       ('孙燕姿', '13501233653', '1980-12-09'),
       ('田馥甄', '13651238755', '1983-08-21'),
       ('邓紫棋', '17843283452', '1991-11-12'),
       ('刘若英', '18635575464', '1989-05-18'),
       ('杨超越', '13761238755', '1994-05-11');

SELECT *
FROM beauty;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS get_phone(IN beauty_id INT, OUT beauty_name VARCHAR(15), OUT beauty_phone VARCHAR(15))
BEGIN
    SELECT name, phone
    INTO beauty_name, beauty_phone
    FROM beauty
    WHERE id = beauty_id;
END //

DELIMITER ;

# 调用
SET @beauty_id := 2;
CALL get_phone(@beauty_id, @beauty_name, @beauty_phone);

SELECT @beauty_name, @beauty_phone;

SELECT name, phone
FROM beauty
WHERE id = 2;

# 3. 创建存储过程date_diff()，实现传入两个女神生日，返回日期间隔大小
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS date_diff(IN birth1 DATE, IN birth2 DATE, OUT diff INT)
BEGIN
    SELECT DATEDIFF(birth1, birth2)
    INTO diff;
END //

DELIMITER ;

# 调用
SET @birth1 := '1988-07-17';
SET @birth2 := '1986-04-12';
CALL date_diff(@birth1, @birth2, @diff);

SELECT @diff;

# 4. 创建存储过程format_date(), 实现传入一个日期，格式化成xx年xx月xx日并返回
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS format_date(IN date DATE, OUT formatted_date VARCHAR(20))
BEGIN
    SELECT DATE_FORMAT(date, '%Y年%m月%d日') INTO formatted_date;
END //

DELIMITER ;

# 调用
SET @date := CURDATE();
CALL format_date(@date, @formatted_date);

SELECT @formatted_date;

# 5. 创建存储过程beauty_limit()，根据传入的起始索引和条目数，查询女神表的记录
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS beauty_limit(IN start INT, IN num INT)
BEGIN
    SELECT *
    FROM beauty
    LIMIT start,num;
END //

DELIMITER ;

# 调用
SET @start = 1;
SET @num = 3;

CALL beauty_limit(@start, @num);

# 创建带inout模式参数的存储过程
# 6. 传入a和b两个值，最终a和b都翻倍并返回
DELIMITER //

CREATE PROCEDURE double_it(INOUT a INT, INOUT b INT)
BEGIN
    # SELECT a * 2, b * 2 INTO a,b;
    SET a = a * 2;
    SET b = b * 2;
END //

DELIMITER ;

# 调用
SET @a := 5;
SET @b := 6;
SELECT @a, @b;

CALL double_it(@a, @b);

SELECT @a, @b;

# 7. 删除题目5的存储过程
DROP PROCEDURE IF EXISTS beauty_limit;

# 8. 查看题目6中存储过程的信息
SHOW CREATE PROCEDURE double_it;

SHOW PROCEDURE STATUS LIKE 'double_it';

SELECT *
FROM information_schema.ROUTINES
WHERE ROUTINE_NAME = 'double_it'
  AND ROUTINE_TYPE = 'PROCEDURE';

# 存储函数的练习
# 0. 准备工作
USE test15_pro_func;

CREATE TABLE employees
AS
SELECT *
FROM atguigudb.employees;

CREATE TABLE departments
AS
SELECT *
FROM atguigudb.departments;

#无参有返回
# 1. 创建函数get_count(),返回公司的员工个数
DELIMITER $

CREATE FUNCTION IF NOT EXISTS get_count()
    RETURNS INT
    DETERMINISTIC
    CONTAINS SQL
    READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*) FROM employees);
END $

DELIMITER ;

# 调用
SELECT get_count();

# 有参有返回
# 2. 创建函数ename_salary(), 根据员工姓名，返回它的工资
DESC employees;

DELIMITER $

CREATE FUNCTION IF NOT EXISTS ename_salary(ename VARCHAR(25))
    RETURNS DOUBLE(8, 2)
    DETERMINISTIC
    CONTAINS SQL
    READS SQL DATA
BEGIN
    RETURN (SELECT salary FROM employees WHERE last_name = ename);
END $

DELIMITER ;

# 调用
SELECT ename_salary('Kochhar');

SELECT *
FROM employees
WHERE last_name = 'Kochhar';

# 3. 创建函数dept_sal()，根据部门名，返回该部门的平均工资
DESC departments;

DELIMITER $

CREATE FUNCTION IF NOT EXISTS dept_sal(dept_name VARCHAR(30))
    RETURNS DOUBLE(8, 2)
    DETERMINISTIC
    CONTAINS SQL
    READS SQL DATA
BEGIN
    RETURN
        (SELECT dept_avg_sal.avg_sal
         FROM departments d
                  JOIN
              (SELECT department_id, AVG(salary) avg_sal
               FROM employees
               GROUP BY department_id) dept_avg_sal
              ON d.department_id = dept_avg_sal.department_id
         WHERE d.department_name = dept_name);
END $

DELIMITER ;

# 调用
SET @dept_name = 'Marketing';

SELECT dept_sal(@dept_name);

# 4. 创建函数add_float()，实现传入两个float，返回二者之和
DELIMITER $

CREATE FUNCTION add_float(num1 FLOAT, num2 FLOAT)
    RETURNS FLOAT
    DETERMINISTIC
    CONTAINS SQL
    READS SQL DATA
BEGIN
    RETURN num1 + num2;
END $

DELIMITER ;

# 调用
SET @num1 = 3.4;
SET @num2 = 5.6;

SELECT add_float(@num1, @num2)
```

