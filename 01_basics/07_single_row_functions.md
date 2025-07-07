# 第07章 单行函数

> 32 函数的分类

> 33 数值类型的函数讲解

## 1. 数值函数

### 1.1 基本操作

```mysql
# 基本的操作
SELECT ABS(-123),
       ABS(32),
       SIGN(-23),
       SIGN(43),
       PI(),
       CEIL(32.32),
       CEILING(-43.23),
       FLOOR(32.32),
       FLOOR(-43.23),
       MOD(12, 5),
       12 % 5
FROM DUAL;

# 取随技数
SELECT RAND(), RAND(), RAND(10), RAND(10), RAND(-1), RAND(-1)
FROM DUAL;

# 四舍五入，截断操作
SELECT ROUND(123.456),
       ROUND(123.456, 0),
       ROUND(123.456, 1),
       ROUND(123.456, 2),
       ROUND(123.456, -1),
       ROUND(123.456, -2),
       ROUND(153.456, -2)
FROM DUAL;

SELECT TRUNCATE(123.456, 0), TRUNCATE(123.496, 1), TRUNCATE(129.45, -1)
FROM DUAL;

# 单行函数可以嵌套
SELECT TRUNCATE(ROUND(123.456, 2), 0)
FROM DUAL;
```

### 1.2 角度与弧度的互换

```mysql
SELECT RADIANS(30), RADIANS(45), RADIANS(60), RADIANS(90), DEGREES(2 * PI()), DEGREES(RADIANS(60))
FROM DUAL;
```

### 1.3 三角函数

```mysql
SELECT SIN(RADIANS(30)), DEGREES(ASIN(1)), TAN(RADIANS(45)), DEGREES(ATAN(1))
FROM DUAL;
```

### 1.4 指数和对数

```mysql
SELECT POW(2, 5), POWER(2, 4), EXP(2)
FROM DUAL;

SELECT LN(EXP(2)), LOG(EXP(2)), LOG10(10), LOG2(4)
FROM DUAL;
```

### 1.5 进制间的转换

```mysql
SELECT BIN(10), HEX(10), OCT(10), CONV(10, 10, 8)
FROM DUAL;
```

> 34 字符串类型的函数讲解

## 2. 字符串的函数

```mysql
SELECT ASCII('Abc'), CHAR_LENGTH('hello'), CHAR_LENGTH('我们'), LENGTH('hello'), LENGTH('我们')
FROM DUAL;

# xxx worked for yyy.
SELECT CONCAT(emp.last_name, ' worked for ', mgr.last_name, '.') "Work Info"
FROM employees emp
         JOIN employees mgr
              ON emp.manager_id = mgr.employee_id;

# CONCAT相当于CONCAT_WS一种特殊情况。如果CONCAT_WS的第一个参数为''，那么这两个函数效果相同。
SELECT CONCAT_WS('-', 'hello', 'world', 'hello', 'seoul')
FROM DUAL;

# 字符串的索引是从1开始的。
SELECT INSERT('helloworld', 2, 3, 'aaaaa'), REPLACE('hello', 'll', 'mmm')
FROM DUAL;

SELECT UPPER('Hello'), LOWER('Hello')
FROM DUAL;

SELECT LEFT('hello', 2), RIGHT('hello', 3), RIGHT('hello', 13)
FROM DUAL;

# LPAD: 实现右对齐的效果
# RPAD: 实现左对齐的效果
SELECT employee_id, last_name, LPAD(salary, 10, '*')
FROM employees;

SELECT CONCAT('---', TRIM('     he  ll   o    '), '---'),
       CONCAT('---', LTRIM('     he  ll   o    '), '---'),
       CONCAT('---', RTRIM('     he  ll   o    '), '---'),
       TRIM('e' FROM 'eehelloeeee')
FROM DUAL;

SELECT REPEAT('hello', 4), CONCAT('@', SPACE(5), '@'), STRCMP('abc', 'abd')
FROM DUAL;

SELECT SUBSTR('hello', 2, 2), LOCATE('ll', 'hello')
FROM DUAL;

SELECT ELT(3, 'a', 'b', 'c', 'd'),
       FIELD('mm', 'gg', 'jj', 'mm', 'dd', 'mm'),
       FIND_IN_SET('mm', 'gg,mm,jj,dd,mm,gg')
FROM DUAL;

SELECT employee_id, first_name, last_name, NULLIF(LENGTH(first_name), LENGTH(last_name)) "compare"
FROM employees;
```

