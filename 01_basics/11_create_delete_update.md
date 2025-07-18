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


