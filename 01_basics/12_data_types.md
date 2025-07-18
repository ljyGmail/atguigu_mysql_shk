# 第12章 MySQL数据类型精讲

> 59 MySQL数据类型概述 字符集设置

## 1. 关于属性: `CHARACTER SET NAME`

```mysql
SHOW VARIABLES LIKE 'character_%';

# 创建数据库时指定字符集
CREATE DATABASE IF NOT EXISTS dbtest12 CHARACTER SET 'utf8';

SHOW CREATE DATABASE dbtest12;

USE dbtest12;

# 创建表的时候，指定表的字符集
CREATE TABLE temp
(
    id INT
) CHARACTER SET 'utf8';

SHOW CREATE TABLE temp;

# 创建表，指定表中的字段时，可以指定字段的字符集
CREATE TABLE temp1
(
    id   INT,
    name VARCHAR(15) CHARACTER SET 'gbk'
);

SHOW CREATE TABLE temp1;
```

> 60 整型数据类型讲解

## 2. 整型数据类型

```mysql
USE dbtest12;

CREATE TABLE IF NOT EXISTS test_int1
(
    f1 TINYINT,
    f2 SMALLINT,
    f3 MEDIUMINT,
    f4 INTEGER,
    f5 BIGINT
);

DESC test_int1;

INSERT INTO test_int1(f1)
VALUES (12),
       (-12),
       (-128),
       (127);

SELECT *
FROM test_int1;

# Out of range value for column 'f1' at row 1
INSERT INTO test_int1(f1)
VALUES (128);

CREATE TABLE IF NOT EXISTS test_int2
(
    f1 INT,
    f2 INT(5),
    f3 INT(5) ZEROFILL # 1️⃣显示宽度为5，当insert的值不足5位时，使用0填充。2️⃣当使用ZEROFILL时，自动会添加UNSIGNED。
);

INSERT INTO test_int2(f1, f2)
VALUES (123, 123),
       (123456, 123456);

SELECT *
FROM test_int2;

INSERT INTO test_int2(f3)
VALUES (123),
       (123456);

SHOW CREATE TABLE test_int2;

CREATE TABLE IF NOT EXISTS test_int3
(
    f1 INT UNSIGNED
);

DESC test_int3;

INSERT INTO test_int3
VALUES (2412321);

# Out of range for column 'f1' at row 1
INSERT INTO test_int3
VALUES (4294967296);

SELECT *
FROM test_int3;
```


