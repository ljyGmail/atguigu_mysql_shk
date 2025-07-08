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

> 44 单行子查询案例分析

## 4. 单行子查询

### 4.1 单行操作符: =, !=, >, >=, <, <=

```mysql
# 子查询的编写技巧(或步骤): 1️⃣从里往外写 2️⃣从外往里写

# 题目: 查询工资大于149号员工工资的员工的信息。
SELECT employee_id, last_name, salary
FROM employees
WHERE salary >
      (SELECT salary
       FROM employees
       WHERE employee_id = 149);

# 题目: 返回job_id与141号员工相同，salary比143号员工多的员工姓名，job_id和工资。
SELECT last_name, job_id, salary
FROM employees
WHERE job_id = (SELECT job_id
                FROM employees
                WHERE employee_id = 141)
  AND salary > (SELECT salary
                FROM employees
                WHERE employee_id = 143);

# 题目: 返回公司工资最少的员工的last_name，job_id和salary。
SELECT last_name, job_id, salary
FROM employees
WHERE salary = (SELECT MIN(salary)
                FROM employees);

# 题目: 查询与141号员工的manager_id和department_id相同的其他员工的
# employee_id，manager_id，department_id。
# 方式1:
SELECT employee_id, manager_id, department_id
FROM employees
WHERE manager_id = (SELECT manager_id
                    FROM employees
                    WHERE employee_id = 141)
  AND department_id = (SELECT department_id
                       FROM employees
                       WHERE employee_id = 141)
  AND employee_id <> 141;

# 方式2: 了解
SELECT employee_id, manager_id, department_id
FROM employees
WHERE (manager_id, department_id) = (SELECT manager_id, department_id
                                     FROM employees
                                     WHERE employee_id = 141)
  AND employee_id != 141;

# 题目: 查询最低工资大于110号部门最低工资的部门id和其最低工资。
SELECT department_id, MIN(salary)
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING MIN(salary) > (SELECT MIN(salary)
                      FROM employees
                      WHERE department_id = 110);

# 题目: 查询员工的employee_id, last_name和location。
# 其中，若员工department_id与location_id为1800的department_id相同，
# 则location为'Canada'，其余则为'USA'。
SELECT employee_id,
       last_name,
       CASE department_id
           WHEN (SELECT department_id
                 FROM departments
                 WHERE location_id = 1800) THEN 'Canada'
           ELSE 'USA' END "location"
FROM employees;

SELECT department_id
FROM departments
WHERE location_id = 1800;
```

### 4.2 子查询中的空值问题

```mysql
SELECT last_name, job_id
FROM employees
WHERE job_id = (SELECT job_id
                FROM employees
                WHERE last_name = 'Haas');
```

### 4.3 非法使用子查询

```mysql
# 错误信息: Subquery returns more than 1 row.
SELECT *
FROM employees
WHERE salary = (SELECT MIN(salary)
                FROM employees
                GROUP BY department_id);
```

