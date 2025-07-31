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


