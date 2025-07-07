# 第09章 子查询

> 43 子查询举例与子查询的分类

## 1. 由一个具体的需求，引入子查询

```mysql
# 需求: 谁的工资比Abel的高?
# 方式1:
SELECT salary
FROM employees
WHERE last_name = 'Abel';

SELECT last_name, salary
FROM employees
WHERE salary > 11000;

# 方式2: 自连接
SELECT e2.last_name, e2.salary
FROM employees e1,
     employees e2
WHERE e2.salary > e1.salary # 多表连接的条件
  AND e1.last_name = 'Abel';

# 方式3: 子查询
SELECT last_name, salary
FROM employees
WHERE salary > (SELECT salary
                FROM employees
                WHERE last_name = 'Abel');
```

## 2. 称谓的规范: 外查询(或主查询)、内查询(或子查询)

- 子查询(内查询)在主查询之前一次执行完成。
- 子查询的结果被主查询(外查询)使用。
- **注意事项**:
    - 子查询要包含在括号内。
    - 将子查询放在比较条件的右侧。
    - 单行操作符对应单行子查询，多行操作符对应多行子查询。

```mysql
# 不推荐
# 虽然将子查询写在比较条件的左侧也可以执行，但是可读性有所降低。
SELECT last_name, salary
FROM employees
WHERE (SELECT salary
       FROM employees
       WHERE last_name = 'Abel') < salary;
```

## 3. 子查询的分类

- 角度1: 从内查询返回的结果的条目数
    - 单行子查询 vs 多行子查询
- 角度2: 内查询是否被执行多次
    - 相关子查询 vs 非相关子查询
        - 举例: 相关子查询的需求: 查询工资大于本部门平均工资的员工信息。  
          不相关子查询的需求: 查询工资大于本公司平均工资的员工信息。