# 第11章 数据处理之增删改

> 55 DML之添加数据

```mysql
USE atguigudb;

CREATE TABLE IF NOT EXISTS emp1
(
    id        INT,
    name      VARCHAR(15),
    hire_date DATE,
    salary    DOUBLE(10, 2)
);

DESC emp1;

SELECT *
FROM emp1;

SHOW TABLES;
```

## 1. 添加数据

- 方式1: 一条一条地添加数据

```mysql
# 1️⃣没有指明添加到字段
INSERT INTO emp1
VALUES (1, 'Tom', '2000-12-21', 3400);
# 一定要按照声明的字段的先后顺序添加

# 错误的:
# INSERT INTO emp1
# VALUES (2, 3400, '2000-12-21', 'Jerry');

# 2️⃣指明要添加的字段 (推荐)
INSERT INTO emp1(id, hire_date, salary, name)
VALUES (2, '1999-09-09', 4000, 'Jerry');

# 说明: 没有进行赋值的hire_date的值为null
INSERT INTO emp1(id, salary, name)
VALUES (3, 4500, 'shk');

# 3️⃣一次性插入多条记录 (推荐)
INSERT INTO emp1 (id, name, salary)
VALUES (4, 'Jim', 5000),
       (5, '张俊杰', 5500);
```

- 方式2: 将查询结果插入到表中

```mysql
SELECT *
FROM emp1;

INSERT INTO emp1(id, name, salary, hire_date)
# 查询语句
SELECT employee_id, last_name, salary, hire_date # 查询的字段一定要与添加到的表的字段一一对应
FROM employees
WHERE department_id IN (60, 70);

DESC emp1;
DESC employees;

# 说明: emp1表中要添加数据的字段的长度不能低于employees表中查询的字段的长度。
# 如果emp1表中要添加数据的字段的长度低于employees表中查询的字段的长度，就有添加不成功的风险。
```

> 56 DML之更新删除操作 MySQL8新特性之计算列

## 2. 更新数据(或修改数据)

- UPDATE ... SET ... WHERE
- 可以实现批量修改数据

```mysql
UPDATE emp1
SET hire_date=CURDATE()
WHERE id = 5;

SELECT *
FROM emp1;

# 同时修改一条数据的多个字段
UPDATE emp1
SET hire_date=CURDATE(),
    salary=6000
WHERE id = 4;

# 题目: 将表中姓名中包含字符a的提薪20%。
UPDATE emp1
SET salary=salary * 1.2
WHERE name LIKE '%a%';

# 修改数据时，是可能存在不成功的情况的。(可能是由于约束的影响造成的)
UPDATE employees
SET department_id=10000
WHERE employee_id = 102;
```

## 3. 删除数据

- DELETE FROM ... WHERE ...

```mysql
DELETE
FROM emp1
WHERE id = 1;

SELECT *
FROM emp1;

# 在删除数据时，也有可能因为约束的影响，导致删除失败。
DELETE
FROM departments
WHERE department_id = 50;

# 小结: DML操作默认情况下，执行完以后都会自动提交数据。
# 如果希望执行完以后不自动提交数据，则需要使用SET AUTOCOMMIT = FALSE。
```

## 4. MySQL8的新特性: 计算列

```mysql
USE atguigudb;

CREATE TABLE test1
(
    a INT,
    b INT,
    c INT GENERATED ALWAYS AS (a + b) VIRTUAL # 字段c即为计算列
);

DESC test1;

INSERT INTO test1(a, b)
VALUES (10, 20);

SELECT *
FROM test1;

UPDATE test1
SET a=100;
```


