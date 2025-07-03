# 第03章 基本的SELECT语句

# 1. SQL的分类
/*
DDL: 数据定义语言。 CREATE \ ALTER \ DROP \ RENAME \ TRUNCATE

DML: 数据操作语言。 INSERT \ DELETE \ UPDATE \ SELECT (重中之重)

DCL: 数据控制语言。 COMMIT \ ROLLBACK \ SAVEPOINT \ GRANT \ REVOKE

学习技巧: 大处着眼、小处着手。
 */

/*
2.1 SQL的规则 --- 必须要遵守
- SQL 可以写在一行或者多行。为了提高可读性，各子句分行写，必要时使用缩进
- 每条命令以 ; 或 \g 或 \G 结束
- 关键字不能被缩写也不能分行
- 关于标点符号
    - 必须保证所有的()、单引号、双引号是成对结束的
    - 必须使用英文状态下的半角输入方式
    - 字符串型和日期时间类型的数据可以使用单引号（' '）表示
    - 列的别名，尽量使用双引号（" "），而且不建议省略as

2.2 SQL的规范 --- 建议遵守
- MySQL 在 Windows 环境下是大小写不敏感的
- MySQL 在 Linux 环境下是大小写敏感的
    - 数据库名、表名、表的别名、变量名是严格区分大小写的
    - 关键字、函数名、列名(或字段名)、列的别名(字段的别名) 是忽略大小写的。
- 推荐采用统一的书写规范：
    - 数据库名、表名、表别名、字段名、字段别名等都小写
    - SQL 关键字、函数名、绑定变量等都大写

3. MySQL的三种注释
单行注释：#注释文字(MySQL特有的方式)
单行注释：-- 注释文字(--后面必须包含一个空格。)
多行注释：/ * 注释文字 * /
*/

/*
4. 导入现有的数据表、表的数据
方式1: source 文件的全路径名
举例: source d:\atguigu.sql ;

方式2: 基于具体的图形化界面的工具可以导入数据
 */

# 5. 最基本的SELECT语句 SELECT 字段1, 字段2... FROM 表名
SELECT 1 + 1, 3 * 2;
SELECT 1 + 1, 3 * 2
FROM DUAL;
# DUAL： 伪表

# *: 表中的所有的字段(或列)
SELECT *
FROM employees;

SELECT employee_id, last_name, salary
FROM employees;

# 6. 列的别名
# AS 全称: alias(别名)，可以省略
# 列的别名可以使用一对双引号("")引起来，不要使用单引号('')。
SELECT employee_id emp_id, last_name AS lname, department_id "部门id", salary * 12 "annual sal"
FROM employees;

# 7. 去除重复行
# 查询员工表中一共有哪些部门id?
# 错误的: 没有去重的情况
SELECT department_id
FROM employees;
# 正确的: 去重的情况
SELECT DISTINCT department_id
FROM employees;

# 错误的:
/*
SELECT salary, DISTINCT department_id
FROM employees;
 */

# 仅仅是没有报错，但是没有实际意义。
SELECT DISTINCT salary, department_id
FROM employees;

# 8. 空值参与运算
## 1. 空值: NULL
## 2. NULL不等同于0，''，'NULL'
SELECT *
FROM employees;

## 3. 空值参与运算: 结果一定也为空
SELECT employee_id, salary "月工资", salary * (1 + commission_pct) * 12 "年工资", commission_pct
FROM employees;

# 实际问题的解决方案: 引入IFNULL
SELECT employee_id, salary "月工资", salary * (1 + IFNULL(commission_pct, 0)) * 12 "年工资", commission_pct
FROM employees;

# 9. 着重号 ``
SELECT *
FROM `order`;

# 10. 查询常数
SELECT '尚硅谷', 123, employee_id, last_name
FROM employees;

# 11. 显示表结构
DESCRIBE employees; # 显示了表中字段的详细信息

DESC departments;

# 12. 过滤数据

# 练习: 查询90号部门对员工信息
SELECT *
FROM employees
# 过滤条件，声明在FROM结构的后面
WHERE department_id = 90;

# 练习: 查询last_name为'King'对员工信息
SELECT *
FROM employees
WHERE last_name = 'King';


