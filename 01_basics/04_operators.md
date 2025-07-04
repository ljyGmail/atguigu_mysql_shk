# 第04章 运算符

> 18 算术运算符的使用

## 1. 算术运算符: +, -, *, /, div, %, mod
```mysql
SELECT 100, 100 + 0, 100 - 0, 100 + 50, 100 + 50 * 30, 100 + 35.5, 100 - 35.5
FROM DUAL;

# 在SQL中，+没有连接的作用，只表示加法运算。此时，会将字符串转换为数值(隐式转换)
SELECT 100 + '1' # 在Java语言中，结果是: 1001。
FROM DUAL; # -> 101

SELECT 100 + 'a' # 此时将'a'当作0来处理。
FROM DUAL; # -> 100

SELECT 100 + NULL # NULL值参与运算，结果为NULL。
FROM DUAL; # -> NULL

SELECT 100,
       100 * 1,
       100 * 1.0,
       100 / 1.0,
       100 / 2,
       100 + 2 * 5 / 2,
       100 / 3,
       100 DIV 0 # 分母如果为0，则结果为NULL
FROM DUAL;

# 取模运算: % MOD
SELECT 12 % 3, 12 % 5, 12 MOD -5, -12 % 5, -12 % -5
FROM DUAL;

# 练习: 查询员工id为偶数的员工信息。
SELECT employee_id, last_name, salary
FROM employees
WHERE employee_id % 2 = 0;
```

