# 第13章 约束

> 66 数据完整性与约束的分类

## 1. 基础知识

### 1.1 为什么需要约束? 为了保证数据的完整性!

### 1.2 什么叫约束? 对表中字段的限制。

### 1.3 约束的分类:

- 角度1: 约束的字段的个数
    - 单列约束 vs 多列约束
- 角度2: 约束的作用范围
    - 列级约束: 将此约束声明在对应字段的后面
    - 表级约束: 在表中所有字段声明完，在所有字段的后面什么的约束
- 角度3: 约束的作用(或功能)
    1. NOT NULL (非空约束)
    2. UNIQUE (唯一性约束)
    3. PRIMARY KEY (主键约束)
    4. FOREIGN KEY (外键约束)
    5. CHECK (检查约束)
    6. DEFAULT (默认值约束)

### 1.4 如何添加约束?

- CREATE TABLE时添加约束
- ALTER TABLE时增加约束、删除约束

> 67 非空约束的使用

## 2. 如何查看表中的约束

```mysql
SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test1';
```

## 3. NOT NULL (非空约束)

### 3.1 在CREATE TABLE时添加约束

```mysql
CREATE DATABASE IF NOT EXISTS dbtest13;

USE dbtest13;

CREATE TABLE IF NOT EXISTS test1
(
    id        INT         NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    email     VARCHAR(25),
    salary    DECIMAL(10, 2)
);

SHOW TABLES;

DESC test1;

INSERT INTO test1 (id, last_name, email, salary)
VALUES (1, 'Tom', 'tom@126.com', 3400);

# 错误: Column 'last_name' cannot be null
INSERT INTO test1 (id, last_name, email, salary)
VALUES (2, NULL, 'tom@126.com', 3400);

# 错误: Column 'id' cannot be null
INSERT INTO test1 (id, last_name, email, salary)
VALUES (NULL, 'Jerry', 'jerry@126.com', 3400);

# 错误: Field 'last_name' doesn't have a default value
INSERT INTO test1 (id, email)
VALUES (2, 'abc@126.com');

UPDATE test1
SET email=NULL
WHERE id = 1;

# 错误: Column 'last_name' cannot be null
UPDATE test1
SET last_name=NULL
WHERE id = 1;

SELECT *
FROM test1;
```

### 3.2 在ALTER TABLE时添加约束

```mysql
DESC test1;

# Date truncation: Invalid use of NULL value
ALTER TABLE test1
    MODIFY email VARCHAR(25) NOT NULL;

UPDATE test1
SET email='tom@126'
WHERE id = 1;

ALTER TABLE test1
    MODIFY email VARCHAR(25) NOT NULL;

SELECT *
FROM test1;
```

### 3.3 在ALTER TABLE时删除约束

```mysql
DESC test1;

ALTER TABLE test1
    MODIFY email VARCHAR(25) NULL;

DESC test1;
```

> 68 唯一性约束的使用

## 4. UNIQUE (唯一性约束)

### 4.1 在CREATE TABLE时添加约束

```mysql
CREATE TABLE IF NOT EXISTS test2
(
    id        INT UNIQUE, # 列级约束
    last_name VARCHAR(15),
    email     VARCHAR(25),
    salary    DECIMAL(10, 2),
    # 表级约束
    CONSTRAINT uk_test2_email UNIQUE (email)
    # CONSTRAINT uk_test2_email的部分可以省略，即不给该唯一性约束起名
);

DESC test2;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test2';
# 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同。

INSERT INTO test2(id, last_name, email, salary)
VALUES (1, 'Tom', 'tom@126.com', 4500);

# 错误: Duplicate entry '1' for key 'test2.id'
INSERT INTO test2(id, last_name, email, salary)
VALUES (1, 'Tom1', 'tom1@126.com', 4600);

# 错误: Duplicate entry 'tom@126.com' for key 'test2.email'
INSERT INTO test2(id, last_name, email, salary)
VALUES (2, 'Tom', 'tom@126.com', 4600);

# 可以向声明为UNIQUE的字段上添加NULL值。而且可以多次添加NULL值。
INSERT INTO test2(id, last_name, email, salary)
VALUES (2, 'Tom', NULL, 4600);

INSERT INTO test2(id, last_name, email, salary)
VALUES (3, 'Tom2', NULL, 4600);

SELECT *
FROM test2;
```

### 4.2 在ALTER TABLE时添加约束

```mysql
DESC test2;

UPDATE test2
SET salary=5000
WHERE id = 3;

# 方式1:
ALTER TABLE test2
    ADD CONSTRAINT uk_test2_sal UNIQUE (salary);

# 方式2:
ALTER TABLE test2
    MODIFY last_name VARCHAR(15) UNIQUE;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test2';
```

### 4.3 复合的唯一性约束

```mysql
CREATE TABLE IF NOT EXISTS user
(
    id       INT,
    name     VARCHAR(15),
    password VARCHAR(25),
    # 表级约束
    CONSTRAINT uk_user_name_password UNIQUE (name, password)
);

DESC user;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'user';

INSERT INTO user (id, name, password)
VALUES (1, 'Tom', 'abc');

# 可以添加成功的
INSERT INTO user (id, name, password)
VALUES (2, 'Tom1', 'abc');

# 错误: Duplicate entry 'Tom-abc' for key 'user.uk_user_name_password'
INSERT INTO user (id, name, password)
VALUES (3, 'Tom', 'abc');

SELECT *
FROM user;

# 案例: 复合的唯一性约束的案例
#学生表
CREATE TABLE IF NOT EXISTS student
(
    sid    INT,                 #学号
    sname  VARCHAR(20),         #姓名
    tel    CHAR(11) UNIQUE KEY, #电话
    cardid CHAR(18) UNIQUE KEY  #身份证号
);
#课程表
CREATE TABLE IF NOT EXISTS course
(
    cid   INT,        #课程编号
    cname VARCHAR(20) #课程名称
);
#选课表
CREATE TABLE IF NOT EXISTS student_course
(
    id    INT,
    sid   INT,            # 学号
    cid   INT,            # 课程编号
    score INT,
    UNIQUE KEY (sid, cid) #复合唯一
);

INSERT INTO student
VALUES (1, '张三', '13710011002', '101223199012015623'); # 成功
INSERT INTO student
VALUES (1, '李四', '13710011003', '101223199012015624'); # 成功

INSERT INTO course
VALUES (1001, 'Java'),
       (1002, 'MySQL'); # 成功

SELECT *
FROM student;

SELECT *
FROM course;

INSERT INTO student_course
VALUES (1, 1, 1001, 89),
       (2, 1, 1002, 90),
       (3, 2, 1001, 88),
       (4, 2, 1002, 56); # 成功

SELECT *
FROM student_course;

# 错误: Duplicate entry '2-1002' for key 'student_course.sid'
INSERT INTO student_course
VALUES (5, 2, 1002, 67);
```

### 4.4 删除唯一性约束

- 添加唯一性约束的列上也会自动创建唯一索引。
- 删除唯一约束只能通过删除唯一索引的方式删除。
- 删除时需要指定唯一索引名，唯一索引名就和唯一约束名一样。
- 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同；如果是组合列，那么默认和()中排在第一个的列名相同。
  也可以自定义唯一性约束名。

```mysql
SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'student_course';

DESC test2;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test2';

# 如何删除唯一性索引?
ALTER TABLE test2
    DROP INDEX last_name;

ALTER TABLE test2
    DROP INDEX uk_test2_sal;
```

> 69 主键约束的使用

## 5. PRIMARY KEY (主键约束)

### 5.1 在CREATE TABLE时添加约束

```mysql

# 一个表中最多只能有一个主键约束。

# 错误: Multiple primary key defined
CREATE TABLE test3
(
    id        INT PRIMARY KEY, # 列级约束
    last_name VARCHAR(15) PRIMARY KEY,
    salary    DECIMAL(10, 2),
    email     VARCHAR(25)
);

# 主键约束的特征: 非空且唯一，用于唯一地标识表中的一条记录。
CREATE TABLE test4
(
    id        INT PRIMARY KEY, # 列级约束
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2),
    email     VARCHAR(25)
);

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test4';

# MySQL的主键名总是PRIMARY，就算自己命名了主键约束也没有作用。
CREATE TABLE test5
(
    id        INT,                          # 列级约束
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2),
    email     VARCHAR(25),
    # 表级约束
    CONSTRAINT pk_test5_id PRIMARY KEY (id) # 没有必要起名字
);

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'test5';

INSERT INTO test4(id, last_name, salary, email)
VALUES (1, 'Tom', 4500, 'tom@126.com');

# 错误: Duplicate entry '1' from key 'test4.PRIMARY'
INSERT INTO test4(id, last_name, salary, email)
VALUES (1, 'Tom', 4500, 'tom@126.com');

# 错误: Column 'id' cannot be null
INSERT INTO test4(id, last_name, salary, email)
VALUES (NULL, 'Tom', 4500, 'tom@126.com');

SELECT *
FROM test4;

CREATE TABLE user1
(
    id       INT,
    name     VARCHAR(15),
    password VARCHAR(25),
    PRIMARY KEY (name, password)
);

# 如果是多列组合的复合主键约束，那么这些列都不允许为空值，并且组合的值不允许重复。
INSERT INTO user1
VALUES (1, 'Tom', 'abc');

INSERT INTO user1
VALUES (1, 'Tom1', 'abc');

# 错误: Column 'name' cannot be null
INSERT INTO user1
VALUES (1, NULL, 'abc');

SELECT *
FROM user1;
```

### 5.2 在ALTER TABLE时添加约束

```mysql
CREATE TABLE test6
(
    id        INT,
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2),
    email     VARCHAR(25)
);

DESC test6;

ALTER TABLE test6
    ADD PRIMARY KEY (id);
```

### 5.3 删除主键约束 (在实际开发中，不会去删除表中的主键约束！)

```mysql
ALTER TABLE test6
    DROP PRIMARY KEY;
```

> 70 AUTO_INCREMENT

## 6. 自增长列: AUTO_INCREMENT

### 6.1 在CREATE TABLE时添加

```mysql
CREATE TABLE IF NOT EXISTS test7
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    last_name VARCHAR(15)
);

# 开发中，一旦主键作用的字段上声明有AUTO_INCREMENT，则我们在添加数据时，就不要给主键
# 对应的字段去赋值了。
INSERT INTO test7 (last_name)
VALUES ('Tom');

# 当我们向主键(含auto_increment)的字段上添加0或null时，实际上会自动地往上添加指定的字段的字符
INSERT INTO test7 (id, last_name)
VALUES (0, 'Tom');

INSERT INTO test7 (id, last_name)
VALUES (NULL, 'Tom');

INSERT INTO test7 (id, last_name)
VALUES (10, 'Tom');

INSERT INTO test7 (id, last_name)
VALUES (-10, 'Tom');

SELECT *
FROM test7;
```

### 6.2 在ALTER TABLE时添加

```mysql
CREATE TABLE IF NOT EXISTS test8
(
    id        INT PRIMARY KEY,
    last_name VARCHAR(15)
);

DESC test8;

ALTER TABLE test8
    MODIFY id INT AUTO_INCREMENT;
```

### 6.3 在ALTER TABLE时删除

```mysql
ALTER TABLE test8
    MODIFY id INT;

DESC test8;
```

### 6.4 MySQL8.0新特性: 自增变量的持久化

```mysql
# 在MySQL 5.7中演示

# 在MySQL 8.0中演示
CREATE TABLE test9
(
    id INT PRIMARY KEY AUTO_INCREMENT
);

INSERT INTO test9(id)
VALUES (0),
       (0),
       (0),
       (0);

SELECT *
FROM test9;

DELETE
FROM test9
WHERE id = 4;

SELECT *
FROM test9;

INSERT INTO test9 (id)
VALUES (0);

SELECT *
FROM test9;

DELETE
FROM test9
WHERE id = 5;

SELECT *
FROM test9;

# 重启服务器
INSERT INTO test9 (id)
VALUES (0);

SELECT *
FROM test9;

# MySQL8将自增主键的计数器持久化到重做日志中。每次计数器发生改变，都会将其写入到重做日志中。
# 如果数据库重启，InnoDB会根据日志中信息来初始化计数器的内存值。
# 同样的实验在MySQL5.7中进行，重启数据库服务器后插入数据的ID只能是当前最大ID的值+1。
```

> 71 外键约束的使用

## 7. 外键约束 (Foreign Key)

### 7.1 在CREATE TABLE时添加

```mysql
# 主表和从表: 父表和子表

# 1️⃣ 先创建主表
CREATE TABLE dept1
(
    dept_id   INT,
    dept_name VARCHAR(15)
);

# 2️⃣ 再创建从表
CREATE TABLE emp1
(
    emp_id        INT PRIMARY KEY AUTO_INCREMENT,
    emp_name      VARCHAR(15),
    department_id INT,
    # 表级约束
    CONSTRAINT fk_emp1_dept_id FOREIGN KEY (department_id) REFERENCES dept1 (dept_id)
);

# 上述操作报错，因为主表中的dept_id上没有主键约束或唯一性约束。
# 3️⃣ 添加主键约束
ALTER TABLE dept1
    ADD PRIMARY KEY (dept_id);

DESC dept1;

# 4️⃣ 再创建从表
CREATE TABLE emp1
(
    emp_id        INT PRIMARY KEY AUTO_INCREMENT,
    emp_name      VARCHAR(15),
    department_id INT,
    # 表级约束
    CONSTRAINT fk_emp1_dept_id FOREIGN KEY (department_id) REFERENCES dept1 (dept_id)
);

DESC emp1;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'emp1';
```

### 7.2 演示外键的效果

```mysql
# 添加失败
INSERT INTO emp1 (emp_id, emp_name, department_id)
VALUES (1001, 'Tom', 10);

# 在主表中插入10号部门的数据
INSERT INTO dept1 (dept_id, dept_name)
VALUES (10, 'IT');

# 在主表dept1中添加了10号部门以后，就可以在从表中添加10号部门的员工了
INSERT INTO emp1 (emp_id, emp_name, department_id)
VALUES (1001, 'Tom', 10);

# 删除失败
DELETE
FROM dept1
WHERE dept_id = 10;

# 更新失败
UPDATE dept1
SET dept_id=20
WHERE dept_id = 10;
```

### 7.3 在ALTER TABLE时添加外键约束

```mysql
CREATE TABLE dept2
(
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(15)
);

CREATE TABLE emp2
(
    emp_id        INT PRIMARY KEY AUTO_INCREMENT,
    emp_name      VARCHAR(15),
    department_id INT
);

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'emp2';

ALTER TABLE emp2
    ADD CONSTRAINT fk_emp2_dept_id FOREIGN KEY (department_id) REFERENCES dept2 (dept_id);
```

### 7.4 约束等级

- Cascade方式: 在父表上update/delete记录时，同步update/delete掉子表的匹配记录
- Set null方式: 在父表上update/delete记录时，将子表上匹配记录的列设为null，但是要注意子
  表的外键列不能为not null
- No action方式: 如果子表中有匹配的记录，则不允许对父表对应候选键进行update/delete操作
- Restrict方式: 同no action， 都是立即检查外键约束
- Set default方式: （在可视化工具SQLyog中可能显示空白）：父表有变更时，子表将外键列设置
  成一个默认的值，但Innodb不能识别

```mysql
# 演示: ON UPDATE CASCADE ON DELETE SET NULL
CREATE TABLE dept
(
    did   INT PRIMARY KEY, # 部门编号
    dname VARCHAR(50)      # 部门名称
);

CREATE TABLE emp
(
    eid    INT PRIMARY KEY, # 员工编号
    ename  VARCHAR(5),      # 员工姓名
    deptid INT,             # 员工所在的部门
    FOREIGN KEY (deptid) REFERENCES dept (did) ON UPDATE CASCADE ON DELETE SET NULL
    # 把修改操作设置为级联修改等级，把删除操作设置为SET NULL等级
);

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'emp';

INSERT INTO dept (did, dname)
VALUES (1001, '教学部'),
       (1002, '财务部'),
       (1003, '咨询部');

INSERT INTO emp (eid, ename, deptid) # 在添加这条记录时，要求部门表有1001部门
VALUES (1, '张三', 1001),
       (2, '李四', 1001),
       (3, '王五', 1002);

SELECT *
FROM dept;

SELECT *
FROM emp;

UPDATE dept
SET did=1004
WHERE did = 1002;

DELETE
FROM dept
WHERE did = 1004;

# 结论: 对于外键约束，最好是采用: `ON UPDATE CASCADE ON DELETE RESTRICT`的方式
```

### 7.5 删除外键的约束

```mysql
# 一个表中可以声明有多个外键约束
USE atguigudb;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'employees';

USE dbtest13;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'emp1';

# 删除外键约束
ALTER TABLE emp1
    DROP FOREIGN KEY fk_emp1_dept_id;

# 再手动删除外键约束对应的普通索引
SHOW INDEX FROM emp1;

ALTER TABLE emp1
    DROP INDEX fk_emp1_dept_id;
```

> 72 检查约束与默认值约束

## 8. CHECK约束

```mysql
# MySQL5.7不支持CHECK约束，MySQL8.0支持CHECK约束。
CREATE TABLE test10
(
    id        INT,
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2) CHECK (salary > 2000)
);

INSERT INTO test10 (id, last_name, salary)
VALUES (1, 'Tom', 2500);

# 添加失败
INSERT INTO test10 (id, last_name, salary)
VALUES (2, 'Tom1', 1500);

SELECT *
FROM test10;
```

## 9. DEFAULT约束

### 9.1 在CREATE TABLE时添加约束

```mysql
CREATE TABLE test11
(
    id        INT,
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2) DEFAULT 2000
);

DESC test11;

INSERT INTO test11(id, last_name, salary)
VALUES (1, 'Tom', 3000);

INSERT INTO test11(id, last_name)
VALUES (2, 'Tom1');

SELECT *
FROM test11;
```

### 9.2 在ALTER TABLE时添加约束

```mysql
CREATE TABLE test12
(
    id        INT,
    last_name VARCHAR(15),
    salary    DECIMAL(10, 2)
);

DESC test12;

ALTER TABLE test12
    MODIFY salary DECIMAL(10, 2) DEFAULT 2500;
```

### 9.3 在ALTER TABLE时删除约束

```mysql
ALTER TABLE test12
    MODIFY salary DECIMAL(10, 2);

DESC test12;
```

> 73 第13章 约束 课后练习

## 课后练习

```mysql
# 基础练习
# 练习1:
CREATE DATABASE IF NOT EXISTS test04_emp;

USE test04_emp;

CREATE TABLE IF NOT EXISTS emp2
(
    id       INT,
    emp_name VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS dept2
(
    id        INT,
    dept_name VARCHAR(15)
);

SHOW TABLES;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'test04_emp'
  AND TABLE_NAME = 'emp2';

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'test04_emp'
  AND TABLE_NAME = 'dept2';

# 1. 向表emp2的id列中添加PRIMARY KEY约束
ALTER TABLE emp2
    ADD PRIMARY KEY (id);

# 2. 向表dept2的id列中添加PRIMARY KEY约束
ALTER TABLE dept2
    ADD PRIMARY KEY (id);

# 3. 向表emp2中添加列dept_id，并在其中定义FOREIGN KEY约束，与之相关联的列是dept2表中的id列。
ALTER TABLE emp2
    ADD COLUMN dept_id INT;

ALTER TABLE emp2
    ADD CONSTRAINT fk_emp2_dept_id FOREIGN KEY (dept_id) REFERENCES dept2 (id);

# 练习2: 承接《第11章_数据处理之增删改》的综合案例。

# 1. 创建数据库test01_library
USE test01_library;

# 2. 创建表 books，表结构如下：
```

![img.png](images/73_a_practice_2_2.png)

```mysql
DESC books;

SELECT *
FROM information_schema.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'test01_library'
  AND TABLE_NAME = 'books';

# 3. 使用ALTER语句给books按如下要求增加相应的约束
```

![img_1.png](images/73_b_practice_2_3.png)

```mysql
# 方式1: 主键和自增分开添加
# ALTER TABLE books
#   ADD PRIMARY KEY (id);

# ALTER TABLE books
#   MODIFY id INT AUTO_INCREMENT;

# 方式2: 主键和自增一起添加
ALTER TABLE books
    MODIFY id INT PRIMARY KEY AUTO_INCREMENT;

# 针对于非ID字段的操作
ALTER TABLE books
    MODIFY name VARCHAR(50) NOT NULL;

ALTER TABLE books
    MODIFY authors VARCHAR(100) NOT NULL;

ALTER TABLE books
    MODIFY price FLOAT NOT NULL;

ALTER TABLE books
    MODIFY pubdate YEAR NOT NULL;

ALTER TABLE books
    MODIFY num INT NOT NULL;

# 练习3:
# 1. 创建数据库test04_company
CREATE DATABASE IF NOT EXISTS test04_company CHARACTER SET 'utf8';

USE test04_company;

# 2. 按照下表给出的表结构在test04_company数据库中创建两个数据表offices和employees
```

![img.png](images/73_c_practice_3_2.png)

```mysql
CREATE TABLE IF NOT EXISTS offices
(
    officeCode INT PRIMARY KEY,
    city       VARCHAR(50) NOT NULL,
    address    VARCHAR(50),
    country    VARCHAR(50) NOT NULL,
    postalCode VARCHAR(50) UNIQUE
);

CREATE TABLE IF NOT EXISTS employees
(
    employeeNumber INT PRIMARY KEY AUTO_INCREMENT,
    lastName       VARCHAR(50) NOT NULL,
    firstName      VARCHAR(50) NOT NULL,
    mobile         VARCHAR(25) UNIQUE,
    officeCode     INT         NOT NULL,
    jobTitle       VARCHAR(25) NOT NULL,
    birth          DATETIME    NOT NULL,
    note           VARCHAR(255),
    sex            VARCHAR(5),
    CONSTRAINT fk_emp_offcode FOREIGN KEY (officeCode) REFERENCES offices (officeCode)
);

SHOW TABLES;

DESC offices;
DESC employees;

# 3. 将表employees的mobile字段修改到officeCode字段后面
ALTER TABLE employees
    MODIFY mobile VARCHAR(25) AFTER officeCode;

DESC employees;

# 4. 将表employees的birth字段改名为employee_birth
ALTER TABLE employees
    CHANGE birth employee_birth DATETIME;

DESC employees;

# 5. 修改sex字段，数据类型为CHAR(1)，非空约束
ALTER TABLE employees
    MODIFY sex CHAR(1) NOT NULL;

DESC employees;

# 6. 删除字段note
ALTER TABLE employees
    DROP COLUMN note;

DESC employees;

# 7. 增加字段名favorite_activity，数据类型为VARCHAR(100)
ALTER TABLE employees
    ADD COLUMN favorite_activity VARCHAR(100);

DESC employees;

# 8. 将表employees名称修改为employees_info
RENAME TABLE employees TO employees_info;

SHOW TABLES;
```


