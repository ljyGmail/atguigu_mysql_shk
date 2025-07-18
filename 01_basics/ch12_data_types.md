# 第12章 MySQL数据类型精讲

> 59 MySQL数据类型概述 字符集设置

- 关于属性: `CHARACTER SET NAME`

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


