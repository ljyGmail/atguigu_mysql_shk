# 第07章 单行函数

> 32 函数的分类

> 33 数值类型的函数讲解

## 1. 数值函数

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

## 2. 角度与弧度的互换

```mysql
SELECT RADIANS(30), RADIANS(45), RADIANS(60), RADIANS(90), DEGREES(2 * PI()), DEGREES(RADIANS(60))
FROM DUAL;
```

## 3. 三角函数

```mysql
SELECT SIN(RADIANS(30)), DEGREES(ASIN(1)), TAN(RADIANS(45)), DEGREES(ATAN(1))
FROM DUAL;
```

## 4. 指数和对数

```mysql
SELECT POW(2, 5), POWER(2, 4), EXP(2)
FROM DUAL;

SELECT LN(EXP(2)), LOG(EXP(2)), LOG10(10), LOG2(4)
FROM DUAL;
```

## 4. 进制间的转换

```mysql
SELECT BIN(10), HEX(10), OCT(10), CONV(10, 10, 8)
FROM DUAL;
```

