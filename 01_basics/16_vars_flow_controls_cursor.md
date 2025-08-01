# 第16章 变量、流程控制与游标

> 83 GLOBAL与SESSION系统变量的使用

## 1. 变量

### 1.1 变量: 系统变量(全局系统变量、会话系统变量) VS 用户自定义变量

### 1.2 查看系统变量

```mysql
# 查询全局系统变量
SHOW GLOBAL VARIABLES;
# 624

# 查询会话系统变量
SHOW SESSION VARIABLES;
# 648

# 默认查询的是会话系统变量
SHOW VARIABLES;

# 查询部分系统变量
SHOW GLOBAL VARIABLES LIKE 'admin_%';

SHOW VARIABLES LIKE 'character_%';
```

### 1.3 查看指定系统变量

```mysql
SELECT @@global.max_connections;
SELECT @@global.character_set_client;

# 错误: Variable 'pseudo_thread_id' is a SESSION variable
SELECT @@global.pseudo_thread_id;

# 错误: Variable 'max_connections' is a GLOBAL variable
# SELECT @@session.max_connections;

SELECT @@session.character_set_client;

SELECT @@session.pseudo_thread_id;

SELECT @@character_set_client; # 先查询会话系统变量，再查询全局系统变量。
```

### 1.4 修改系统变量的值

```mysql
# 全局系统变量:
# 方式1:
SET @@global.max_connections = 161;

# 方式2:
SET GLOBAL MAX_CONNECTIONS = 171;

# 针对于当前的数据库实例是有效的，一旦重启mysql服务，就失效了。

# 会话系统变量:
# 方式1:
SET @@session.character_set_client = 'gbk';

# 方式2:
SET SESSION CHARACTER_SET_CLIENT = 'gbk';

# 针对于当前会话是有效的，一旦结束会话，重新建立起新的会话，就失效了。
```

> 84 会话用户变量与局部变量的使用

### 1.5 用户变量

```mysql
# 1️⃣ 用户变量: 会话用户变量 VS 局部变量
# 2️⃣ 会话用户变量: 使用"@"开头，作用域为当前会话。
# 3️⃣ 局部变量: 是能使用在存储过程和存储函数中。
```

### 1.6 会话用户变量

```mysql
# 1️⃣ 变量的声明和赋值:
# 方式1: "="或":="
# SET @用户变量 = 值;
# SET @用户变量 := 值;

# 方式2: ":="或INTO关键字
# SELECT @用户变量 := 表达式 [FROM 等字句]
# SELECT 表达式 INTO @用户变量 [FROM 等字句]

# 2️⃣ 使用
# SELECT @变量名;

# 准备工作
CREATE DATABASE IF NOT EXISTS dbtest16;

USE dbtest16;

CREATE TABLE IF NOT EXISTS employees
AS
SELECT *
FROM atguigudb.employees;

CREATE TABLE IF NOT EXISTS departments
AS
SELECT *
FROM atguigudb.departments;

SELECT *
FROM employees;

SELECT *
FROM departments;

# 测试
# 方式1:
SET @m1 = 1;
SET @m2 := 2;
SET @sum := @m1 + @m2;

SELECT @sum;

# 方式2:
SELECT @count := COUNT(*)
FROM employees;

SELECT @count;

SELECT AVG(salary)
INTO @avg_sal
FROM employees;

SELECT @avg_sal;
```

### 1.7 局部变量

```mysql
# 1. 局部变量必须满足:
# 1️⃣ 使用DECLARE声明 
# 2️⃣ 声明并使用在BEGIN ... END中 (使用在存储过程、函数中)
# 3️⃣ DECLARE声明的局部变量必须声明在BEGIN中的首行

# 2. 声明格式:
# DECLARE 变量名 类型 [DEFAULT 值]; # 如果没有DEFAULT子句，初始值为NULL。

# 3. 赋值:
# 方式1:
# SET 变量名 = 值;
# SET 变量名 := 值;

# 方式2:
# SELECT 字段名或表达式 INTO 变量名 FROM 表;

# 4. 使用:
# SELECT 局部变量名;

# 举例:
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS test_var()
BEGIN
    # 1. 声明局部变量
    DECLARE a INT DEFAULT 0;
    DECLARE b INT;
    # DECLARE a, b INT DEFAULT 0; # 如果局部变量的类型和默认值相同，则可以将多个声明语句合并。
    DECLARE emp_name VARCHAR(25);

    # 2. 赋值
    SET a = 1;
    SET b := 2;
    SELECT last_name INTO emp_name FROM employees WHERE employee_id = 101;

    # 3. 使用
    SELECT a, b, emp_name;
END //

DELIMITER ;

# 调用存储过程
CALL test_var();

# 举例1: 声明局部变量，并分别赋值为employees表中employee_id为102的last_name和salary。
DESC employees;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS show_name_salary()
BEGIN
    # 声明
    DECLARE emp_name VARCHAR(25);
    DECLARE emp_salary DOUBLE(10, 2) DEFAULT 0.0;

    # 赋值
    SELECT last_name, salary INTO emp_name,emp_salary FROM employees WHERE employee_id = 102;

    # 使用
    SELECT emp_name, emp_salary;
END //

DELIMITER ;

# 调用
CALL show_name_salary();

SELECT last_name, salary
FROM employees
WHERE employee_id = 102;

# 举例2: 声明两个变量，求和并打印 (分别使用会话用户变量、局部变量的方式实现)。
# 方式1: 使用会话用户变量
SET @num1 := 10;
SET @num2 := 20;
SET @sum := @num1 + @num2;

# 查看
SELECT @sum;

# 方式2: 使用局部变量
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS test_sum()
BEGIN
    # 声明
    DECLARE num1 INT;
    DECLARE num2 INT;
    DECLARE sum_val INT;

    # 赋值
    SET num1 := 14;
    SET num2 := 15;
    SET sum_val := num1 + num2;

    # 使用
    SELECT sum_val;
END //

DELIMITER ;

# 调用
CALL test_sum();

# 举例3: 创建存储过程“different_salary”查询某员工和他领导的薪资差距，并用IN参数emp_id接收员工id，用OUT参数dif_salary输出薪资差距结果。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS different_salary(IN emp_id INT, OUT dif_salary DOUBLE)
BEGIN
    # 分析: 查询出emp_id员工的工资；查询出emp_id员工的管理者的id；查询管理者的工资；计算两个工资的差值。
    # 声明变量
    DECLARE emp_salary, mgr_salary DOUBLE DEFAULT 0.0; # 记录员工和管理者的工资
    DECLARE mgr_id INT DEFAULT 0; # 记录管理者的id

    SELECT salary, manager_id INTO emp_salary, mgr_id FROM employees WHERE employee_id = emp_id;

    SELECT salary INTO mgr_salary FROM employees WHERE employee_id = mgr_id;

    SET dif_salary = mgr_salary - emp_salary;
    # SELECT (mgr_salary - emp_salary) INTO dif_salary;
END //

DELIMITER ;

# 调用
SET @emp_id := 102;
CALL different_salary(@emp_id, @dif_salary);

SELECT @dif_salary;

# 验证结果
SELECT *
FROM employees
WHERE employee_id = 102; # salary: 17000, manager_id: 100

SELECT *
FROM employees
WHERE employee_id = 100; # salary: 24000
```

> 85 程序出错的处理机制

## 2. 定义条件和处理程序

### 2.1 错误演示

```mysql
# 演示
# 错误代码: 1364
# Field 'email' doesn't have a default value
INSERT INTO employees(last_name)
VALUES ('Tom');

DESC employees;

# 错误演示
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS UpdateDataNoCondition()
BEGIN
    SET @x = 1;
    UPDATE employees SET email=NULL WHERE last_name = 'Abel';
    SET @x = 2;
    UPDATE employees SET email='aabbel' WHERE last_name = 'Abel';
    SET @x = 3;
END //

DELIMITER ;

# 调用存储过程
# 错误代码: 1048
# Column 'email' cannot be null
CALL UpdateDataNoCondition();

SELECT @x;
```

### 2.2 定义条件

```mysql
# 格式: DECLARE 错误名称 CONDITION FOR 错误码(或错误条件)

# 举例1: 定义“Field_Not_Be_NULL”错误名与MySQL中违反非空约束的错误类型是“ERROR 1048 (23000)”对应。
# 方式1: 使用MySQL_error_code。
# DECLARE Field_Not_Be_NULL CONDITION FOR 1048;

# 方式2: 使用sqlstate_value。
# DECLARE Field_Not_Be_NULL CONDITION FOR SQLSTATE '23000';

# 举例2：定义"ERROR 1148(42000)"错误，名称为command_not_allowed。
# 方式1: 使用MySQL_error_code。
# DECLARE command_not_allowed CONDITION FOR 1148;

# 方式2: 使用sqlstate_value。
# DECLARE command_not_allowed CONDITION FOR SQLSTATE '42000';
```

### 2.3 定义处理程序

```mysql
# 格式: DECLARE 处理方式 HANDLER FOR 错误类型 处理语句

# 方法1：捕获sqlstate_value
# DECLARE CONTINUE HANDLER FOR SQLSTATE '42S02' SET @info = 'NO_SUCH_TABLE';

# 方法2：捕获mysql_error_value
# DECLARE CONTINUE HANDLER FOR 1146 SET @info = 'NO_SUCH_TABLE';

# 方法3：先定义条件，再调用
# DECLARE no_such_table CONDITION FOR 1146;
# DECLARE CONTINUE HANDLER FOR NO_SUCH_TABLE SET @info = 'NO_SUCH_TABLE';

# 方法4：使用SQLWARNING
# DECLARE EXIT HANDLER FOR SQLWARNING SET @info = 'ERROR';

# 方法5：使用NOT FOUND
# DECLARE EXIT HANDLER FOR NOT FOUND SET @info = 'NO_SUCH_TABLE';

# 方法6：使用SQLEXCEPTION
# DECLARE EXIT HANDLER FOR SQLEXCEPTION SET @info = 'ERROR';
```

### 2.4 案例的处理

```mysql
DROP PROCEDURE IF EXISTS UpdateDataNoCondition;

# 重新定义存储过程，体现错误的处理程序。
DELIMITER //

CREATE PROCEDURE if NOT EXISTS UpdateDataNoCondition()
BEGIN
    # 声明处理程序
    # 处理方式1:
    DECLARE CONTINUE HANDLER FOR 1048 SET @prc_value = -1;
    # 处理方式2:
    # DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' SET @prc_value = -1;

    SET @x = 1;
    UPDATE employees SET email=NULL WHERE last_name = 'Abel';
    SET @x = 2;
    UPDATE employees SET email='aabbel' WHERE last_name = 'Abel';
    SET @x = 3;
END //

DELIMITER ;

# 调用存储过程
CALL UpdateDataNoCondition();

# 查询变量
SELECT @x, @prc_value;
```

### 2.5 再举一个例子:

```mysql
# 创建一个名称为"InsertDataWithCondition"的存储过程

# 1️⃣ 准备工作:
CREATE TABLE IF NOT EXISTS departments
AS
SELECT *
FROM atguigudb.departments;

DESC departments;

ALTER TABLE departments
    ADD CONSTRAINT uk_dept_name UNIQUE (department_id);

# 2️⃣ 定义存储过程:
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS InsertDataWithCondition()
BEGIN
    SET @x = 1;
    INSERT INTO departments(department_name)
    VALUES ('测试');
    SET @x = 2;
    INSERT INTO departments(department_name)
    VALUES ('测试');
    SET @x = 3;
END //

DELIMITER ;

# 3️⃣ 调用
CALL InsertDataWithCondition();

SELECT @x;
# 2

# 4️⃣ 删除此存储过程
DROP PROCEDURE IF EXISTS InsertDataWithCondition;

# 5️⃣ 重新定义存储过程(考虑到错误的处理程序)
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS InsertDataWithCondition()
BEGIN
    # 处理程序
    # 方式1:
    # DECLARE EXIT HANDLER FOR 1062 SET @pro_value = -1;
    # 方式2:
    # DECLARE EXIT HANDLER FOR SQLSTATE '23000' SET @pro_value = -1;
    # 方式3:
    # 定义条件
    DECLARE duplicate_entry CONDITION FOR 1062;
    DECLARE EXIT HANDLER FOR duplicate_entry SET @pro_value = -1;

    SET @x = 1;
    INSERT INTO departments(department_name)
    VALUES ('测试');
    SET @x = 2;
    INSERT INTO departments(department_name)
    VALUES ('测试');
    SET @x = 3;
END //

DELIMITER ;

# 调用
CALL InsertDataWithCondition();

SELECT @x, @pro_value;
```

> 86 分支结构IF的使用

## 3. 流程控制

### 3.1 分支结构之 IF

```mysql
# 举例1:
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS test_if()
BEGIN
    # 情况1:
    # 声明局部变量
    # DECLARE stu_name VARCHAR(15);

    # IF stu_name IS NULL
    # THEN
    #     SELECT 'stu_name is NULL';
    # END IF;

    # 情况2: 二选一
    # DECLARE email VARCHAR(25) DEFAULT 'aaa';

    # IF email IS NULL
    # THEN
    #     SELECT 'email is NULL';
    # ELSE
    #     SELECT 'email is not NULL';
    # END IF;

    # 情况3: 多选一
    DECLARE age INT DEFAULT 20;

    IF age > 40 THEN
        SELECT '中老年';
    ELSEIF age > 18 THEN
        SELECT '青壮年';
    ELSEIF age > 8 THEN
        SELECT '青少年';
    ELSE
        SELECT '婴幼儿';
    END IF;
END //

DELIMITER ;

# 调用
CALL test_if();

DROP PROCEDURE IF EXISTS test_if;

# 举例2: 声明存储过程“update_salary_by_eid1”，定义IN参数emp_id，输入员工编号。判断该员工
# 薪资如果低于8000元并且入职时间超过5年，就涨薪500元; 否则就不变。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS update_salary_by_eid1(IN emp_id INT)
BEGIN
    # 声明局部变量
    DECLARE emp_salary DOUBLE DEFAULT 0.0; # 记录员工的工资
    DECLARE hire_year DOUBLE;
    # 记录员工入职公司的年头

    # 赋值
    SELECT salary, DATEDIFF(CURDATE(), hire_date) / 365
    INTO emp_salary,hire_year
    FROM employees
    WHERE employee_id = emp_id;

    IF emp_salary < 8000 AND hire_year >= 5
    THEN
        UPDATE employees SET salary=salary + 500 WHERE employee_id = emp_id;
    END IF;
END //

DELIMITER ;

# 调用存储过程
SET @emp_id := 104;
CALL update_salary_by_eid1(@emp_id);

SELECT employee_id, salary, hire_date
FROM employees;

# 举例3：声明存储过程“update_salary_by_eid2”，定义IN参数emp_id，输入员工编号。判断该员工
# 薪资如果低于9000元并且入职时间超过5年，就涨薪500元；否则就涨薪100元。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS update_salary_by_eid2(IN emp_id INT)
BEGIN
    # 定义局部变量
    DECLARE emp_salary DOUBLE;
    DECLARE hire_year DOUBLE;

    # 赋值
    SELECT salary INTO emp_salary FROM employees WHERE employee_id = emp_id;

    SELECT DATEDIFF(CURDATE(), hire_date) / 365 INTO hire_year FROM employees WHERE employee_id = emp_id;

    IF emp_salary < 9000 AND hire_year >= 5
    THEN
        UPDATE employees SET salary=salary + 500 WHERE employee_id = emp_id;
    ELSE
        UPDATE employees SET salary=salary + 100 WHERE employee_id = emp_id;
    END IF;
END //

DELIMITER ;

# 调用存储过程
CALL update_salary_by_eid2(102);

SELECT employee_id, salary, hire_date
FROM employees;

# 举例4：声明存储过程“update_salary_by_eid3”，定义IN参数emp_id，输入员工编号。判断该员工
# 薪资如果低于9000元，就更新薪资为9000元；薪资如果大于等于9000元且低于10000的，但是奖金
# 比例为NULL的，就更新奖金比例为0.01；其他的涨薪100元。
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS update_salary_by_eid3(IN emp_id INT)
BEGIN
    # 声明局部变量
    DECLARE emp_salary DOUBLE; # 记录员工的工资
    DECLARE emp_commission_pct DOUBLE;
    # 记录员工的奖金率

    # 赋值
    SELECT salary, commission_pct INTO emp_salary, emp_commission_pct FROM employees WHERE employee_id = emp_id;

    # 判断
    IF emp_salary < 9000
    THEN
        UPDATE employees SET salary=9000 WHERE employee_id = emp_id;
    ELSEIF emp_salary < 10000 AND emp_commission_pct IS NULL
    THEN
        UPDATE employees SET commission_pct=0.01 WHERE employee_id = emp_id;
    ELSE
        UPDATE employees SET salary=salary + 100 WHERE employee_id = emp_id;
    END IF;
END //

DELIMITER ;

# 调用存储过程
CALL update_salary_by_eid3(104);
CALL update_salary_by_eid3(108);

SELECT employee_id, salary, commission_pct
FROM employees;
```





