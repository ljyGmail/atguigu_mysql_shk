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
CREATE TABLE IF NOT EXISTS temp
(
    id INT
) CHARACTER SET 'utf8';

SHOW CREATE TABLE temp;

# 创建表，指定表中的字段时，可以指定字段的字符集
CREATE TABLE IF NOT EXISTS temp1
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

> 61 浮点数、定点数与位类型讲解

## 3. 浮点类型

```mysql
CREATE TABLE IF NOT EXISTS test_double1
(
    f1 FLOAT,
    f2 FLOAT(5, 2),
    f3 DOUBLE,
    f4 DOUBLE(5, 2)
);

DESC test_double1;

INSERT INTO test_double1(f1, f2)
VALUES (123.45, 123.45);

SELECT *
FROM test_double1;

INSERT INTO test_double1(f3, f4)
VALUES (123.45, 123.456); # 存在四舍五入

INSERT INTO test_double1(f3, f4)
VALUES (123.45, 1234.456);
# Ouf of range value for column 'f4' at row 1

# 进位导致超出范围
INSERT INTO test_double1(f3, f4)
VALUES (123.45, 999.995);
# Ouf of range value for column 'f4' at row 1

# 测试FLOAT和DOUBLE的精度问题
CREATE TABLE IF NOT EXISTS test_double2
(
    f1 DOUBLE
);

INSERT INTO test_double2
VALUES (0.47),
       (0.44),
       (0.19);

SELECT SUM(f1)
FROM test_double2; # 1.0999999999999999

SELECT SUM(f1) = 1.1, 1.1 = 1.1
FROM test_double2;
```

## 4. 定点数类型

```mysql
CREATE TABLE IF NOT EXISTS test_decimal1
(
    f1 DECIMAL,
    f2 DECIMAL(5, 2)
);

DESC test_decimal1;

INSERT INTO test_decimal1(f1)
VALUES (123),
       (123.45);

SELECT *
FROM test_decimal1;

INSERT INTO test_decimal1(f2)
VALUES (999.99);

INSERT INTO test_decimal1(f2)
VALUES (67.567);

# Out of range value for column 'f2' at row 1
INSERT INTO test_decimal1(f2)
VALUES (1267.567);

# Out of range value for column 'f2' at row 1
INSERT INTO test_decimal1(f2)
VALUES (999.995);

# 测试DECIMAL类型的精度
CREATE TABLE IF NOT EXISTS test_decimal2
(
    f1 DECIMAL(5, 2)
);

DESC test_decimal2;

INSERT INTO test_decimal2
VALUES (0.47),
       (0.44),
       (0.19);

SELECT SUM(f1)
FROM test_decimal2; # 1.10

SELECT SUM(f1) = 1.1, 1.1 = 1.1
FROM test_decimal2;
```

## 5. 位类型: BIT

```mysql
CREATE TABLE IF NOT EXISTS test_bit1
(
    f1 BIT,
    f2 BIT(5),
    f3 BIT(64) # 最大值为64
);

DESC test_bit1;

INSERT INTO test_bit1(f1)
VALUES (0),
       (1);

SELECT *
FROM test_bit1;

# Data too long for column 'f1' at row 1
INSERT INTO test_bit1(f1)
VALUES (2);

INSERT INTO test_bit1(f2)
VALUES (31);

# Data too long for column 'f2' at row 1
INSERT INTO test_bit1(f2)
VALUES (32);

SELECT BIN(f1), BIN(f2), HEX(f1), HEX(f2)
FROM test_bit1;

# 此时+0以后，可以以十进制的方式显示数据
SELECT f1 + 0, f2 + 0
FROM test_bit1;
```

> 62 日期时间类型讲解

## 6. 日期时间类型

### 6.1 YEAR类型

```mysql
CREATE TABLE IF NOT EXISTS test_year1
(
    f1 YEAR,
    f2 YEAR(4)
);

DESC test_year1;

INSERT INTO test_year1(f1)
VALUES ('2021'),
       (2022);

SELECT *
FROM test_year1;

INSERT INTO test_year1(f1)
VALUES ('2155');

# 错误: Out of range value for column 'f1' at row 1
INSERT INTO test_year1(f1)
VALUES ('2156');

INSERT INTO test_year1(f1)
VALUES ('69'),
       ('70'); # 2069, 1970

INSERT INTO test_year1(f1)
VALUES (0),
       ('00'); # 0, 2000
```

### 6.2 DATE类型

```mysql
CREATE TABLE IF NOT EXISTS test_date1
(
    f1 DATE
);

DESC test_date1;

INSERT INTO test_date1 (f1)
VALUES ('2020-10-01'),
       ('20201001'),
       (20201001);

INSERT INTO test_date1 (f1)
VALUES ('00-01-01'),
       ('000101'),
       ('69-10-01'),
       ('691001'),
       ('70-01-01'),
       ('700101'),
       ('99-01-01'),
       ('990101');

INSERT INTO test_date1 (f1)
VALUES (000301),
       (690301),
       (700301),
       (990301); # 存在隐式的转换

INSERT INTO test_date1 (f1)
VALUES (CURDATE()),
       (CURRENT_DATE()),
       (NOW());

SELECT *
FROM test_date1;
```

### 6.3 TIME类型

```mysql
CREATE TABLE IF NOT EXISTS test_time1
(
    f1 TIME
);

DESC test_time1;

INSERT INTO test_time1 (f1)
VALUES ('2 12:30:29'),
       ('12:35:29'),
       ('12:40'),
       ('2 12:40'),
       ('1 05'),
       ('45');

INSERT INTO test_time1 (f1)
VALUES ('123520'),
       (124011),
       (1210);

INSERT INTO test_time1 (f1)
VALUES (NOW()),
       (CURRENT_TIME()),
       (CURTIME());

SELECT *
FROM test_time1;
```

### 6.4 DATETIME类型

```mysql
CREATE TABLE IF NOT EXISTS test_datetime1
(
    dt DATETIME
);

INSERT INTO test_datetime1 (dt)
VALUES ('2021-01-01 06:50:30'),
       ('20210101060539');

INSERT INTO test_datetime1 (dt)
VALUES ('99-01-01 00:00:00'),
       ('990101000000'),
       ('20-01-01 00:00:00'),
       ('200101000000');

INSERT INTO test_datetime1 (dt)
VALUES (20200101000000),
       (200101000000),
       (19990101000000),
       (990101000000);

INSERT INTO test_datetime1 (dt)
VALUES (CURRENT_TIMESTAMP()),
       (NOW()),
       (SYSDATE());

SELECT *
FROM test_datetime1;
```

### 6.5 TIMESTAMP类型

```mysql
CREATE TABLE IF NOT EXISTS test_timestamp1
(
    ts TIMESTAMP
);

INSERT INTO test_timestamp1 (ts)
VALUES ('1999-01-01 03:04:05'),
       ('19990101030405'),
       ('99-01-01 03:04:05'),
       ('990101030405');

INSERT INTO test_timestamp1 (ts)
VALUES ('2020@01@01@00@00@00'),
       ('20@01@01@00@00@00');

INSERT INTO test_timestamp1 (ts)
VALUES (CURRENT_TIMESTAMP()),
       (NOW());

# 错误: Incorrect datetime value: '2038-01-20 03:14:07' for column 'ts' at row 1
INSERT INTO test_timestamp1 (ts)
VALUES ('2038-01-20 03:14:07');

SELECT *
FROM test_timestamp1;

# 对比DATETIME和TIMESTAMP
CREATE TABLE IF NOT EXISTS temp_time
(
    d1 DATETIME,
    d2 TIMESTAMP
);

INSERT INTO temp_time (d1, d2)
VALUES ('2021-9-2 14:45:52', '2021-9-2 14:45:52');

INSERT INTO temp_time (d1, d2)
VALUES (NOW(), NOW());

SELECT *
FROM temp_time;

# 修改当前的时区
SET TIME_ZONE = '+9:00';

SELECT *
FROM temp_time;

SELECT UNIX_TIMESTAMP();
```

> 63 文本字符串类型(含ENUM、SET)讲解

## 7. 文本字符串类型

### 7.1 CHAR类型

```mysql
CREATE TABLE IF NOT EXISTS test_char1
(
    c1 CHAR,
    c2 CHAR(5)
);

DESC test_char1;

INSERT INTO test_char1 (c1)
VALUES ('a');

# 错误: Data too long for column 'c1' at row 1
INSERT INTO test_char1 (c1)
VALUES ('ab');

INSERT INTO test_char1 (c2)
VALUES ('ab');

INSERT INTO test_char1 (c2)
VALUES ('hello');

INSERT INTO test_char1 (c2)
VALUES ('尚');

INSERT INTO test_char1 (c2)
VALUES ('硅谷');

INSERT INTO test_char1 (c2)
VALUES ('尚硅谷教育');

# 错误: Data too long for column 'c2' at row 1
INSERT INTO test_char1 (c2)
VALUES ('尚硅谷IT教育');

SELECT *
FROM test_char1;

SELECT CONCAT(c2, '***')
FROM test_char1;

INSERT INTO test_char1 (c2)
VALUES ('ab  ');

SELECT CHAR_LENGTH(c2)
FROM test_char1;
```

### 7.2 VARCHAR类型

```mysql
CREATE TABLE test_varchar1
(
    name VARCHAR(10) # 这里必须指明长度，否则报错
);

# 错误: Column length too big for column 'name' (max = 21845); use Blob or TEXT instead
CREATE TABLE test_varchar2
(
    name VARCHAR(65535)
);

CREATE TABLE test_varchar3
(
    name VARCHAR(5)
);

INSERT INTO test_varchar3(name)
VALUES ('尚硅谷'),
       ('尚硅谷教育');

# 错误: Data too long for column 'name' at row 1
INSERT INTO test_varchar3 (name)
VALUES ('尚硅谷IT教育');
```

### 7.3 TEXT类型

```mysql
CREATE TABLE test_text
(
    tx TEXT
);

INSERT INTO test_text (tx)
VALUES ('atguigu   ');

SELECT CHAR_LENGTH(tx)
FROM test_text;

SELECT *
FROM test_text;
```

## 8. ENUM类型

```mysql
CREATE TABLE test_enum
(
    season ENUM ('春','夏', '秋','冬', 'unknown')
);

INSERT INTO test_enum (season)
VALUES ('春'),
       ('秋');

# 错误: Data truncated for column 'season' at row 1
INSERT INTO test_enum (season)
VALUES ('春,秋');

INSERT INTO test_enum (season)
VALUES ('unknown');

# 忽略大小写
INSERT INTO test_enum (season)
VALUES ('UNKNOWN');

# 也可以使用索引进行枚举元素的调用
INSERT INTO test_enum (season)
VALUES (1),
       ('3');

# 没有限制非空的情况下，可以添加NULL值
INSERT INTO test_enum (season)
VALUES (NULL);

# 错误: Data truncated for column 'season' at row 1
INSERT INTO test_enum (season)
VALUES ('人');

SELECT *
FROM test_enum;
```

## 9. SET类型

```mysql
CREATE TABLE test_set
(
    s SET ('A','B','C')
);

INSERT INTO test_set (s)
VALUES ('A'),
       ('A,B');

# 插入重复的SET类型成员时，MySQL会自动删除重复的成员
INSERT INTO test_set (s)
VALUES ('A,B,C,A');

# 向SET类型的字段插入SET成员中不存在的值时，MySQL会抛出错误
# 错误: Data truncated for column 's' at row 1
INSERT INTO test_set (s)
VALUES ('A,B,C,D');

SELECT *
FROM test_set;

CREATE TABLE IF NOT EXISTS temp_mul
(
    gender ENUM ('男','女'),
    hobby  SET ('吃饭', '睡觉', '打豆豆', '写代码')
);

INSERT INTO temp_mul(gender, hobby)
VALUES ('男', '睡觉,打豆豆');

# 错误: Data truncated for column 'gender' at row 1
INSERT INTO temp_mul(gender, hobby)
VALUES ('男,女', '睡觉,打豆豆');

SELECT *
FROM temp_mul;
```

> 64 二进制类型与JSON类型讲解

## 10. 二进制字符串类型

### 10.1 BINARY与VARBINARY类型

```mysql
CREATE TABLE IF NOT EXISTS test_binary
(
    f1 BINARY,
    f2 BINARY(3),
    # f3 VARBINARY,
    f4 VARBINARY(10)
);

DESC test_binary;

INSERT INTO test_binary (f1, f2)
VALUES ('a', 'abc');

# Data too long for column 'f1' at row 1
INSERT INTO test_binary (f1)
VALUES ('ab');

INSERT INTO test_binary (f2, f4)
VALUES ('ab', 'ab');

SELECT *
FROM test_binary;

SELECT LENGTH(f2), LENGTH(f4)
FROM test_binary;
```

### 10.2 BLOB类型

```mysql
CREATE TABLE IF NOT EXISTS test_blob
(
    id  INT,
    img MEDIUMBLOB
);

INSERT INTO test_blob (id)
VALUES (1001);

SELECT *
FROM test_blob;
```

## 11. JSON类型

```mysql
CREATE TABLE IF NOT EXISTS test_json
(
    js JSON
);

INSERT INTO test_json (js)
VALUES ('{"name":"songhk", "age":18, "address": {"province": "Beijing", "city": "Beijing"}}');

SELECT *
FROM test_json;

SELECT js -> '$.name'             AS name,
       js -> '$.age'              AS age,
       js -> '$.address.province' AS province,
       js -> '$.address.city'     AS city
FROM test_json;
```

> 65 小结及类型使用建议

![img.png](images/65_data_type_usage.png)

