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

> 45 多行子查询案例分析

## 5. 多行子查询

### 5.1 多行子查询的操作符: IN, ANY, ALL, SOME(同ANY)

### 5.2 举例

```mysql
# IN:
SELECT employee_id, last_name, salary
FROM employees
WHERE salary IN (SELECT MIN(salary)
                 FROM employees
                 GROUP BY department_id);

# ANY / ALL:
# 题目: 返回其它job_id中比job_id为'IT_PROG'部门任一工资低的员工的员工号、姓名、job_id以及salary。
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id <> 'IT_PROG'
  AND salary < ANY (SELECT salary
                    FROM employees
                    WHERE job_id = 'IT_PROG');

# 题目: 返回其它job_id中比job_id为'IT_PROG'部门所有工资低的员工的员工号、姓名、job_id以及salary。
SELECT employee_id, last_name, job_id, salary
FROM employees
WHERE job_id <> 'IT_PROG'
  AND salary < ALL (SELECT salary
                    FROM employees
                    WHERE job_id = 'IT_PROG');

# 题目: 查询平均工资最低的部门id。
# MySQL中聚合函数是不能嵌套的。
# 方式1:
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (SELECT MIN(avg_sal)
                      FROM (SELECT AVG(salary) avg_sal
                            FROM employees
                            GROUP BY department_id) t_dept_avg_sal);

# 方式2:
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) <= ALL (SELECT AVG(salary)
                           FROM employees
                           GROUP BY department_id);
```

### 5.3 空值问题

```mysql
# 如果NOT IN后面的结果集中存在NULL，那么最终没有结果。
SELECT last_name
FROM employees
WHERE employee_id NOT IN (SELECT manager_id
                          FROM employees);
# WHERE manager_id IS NOT NULL

# 原理:
SELECT 'a' != 'b' AND 'a' != 'c'
FROM DUAL;

SELECT 'a' != 'b' AND 'a' != NULL
FROM DUAL;
```

> 46 相关子查询案例分析

## 6. 相关子查询

### 6.1 相关子查询的案例

```mysql
# 回顾: 查询员工中工资大于本公司平均工资的员工的last_name,salary和其department_id。
SELECT last_name, last_name, department_id
FROM employees
WHERE salary > (SELECT AVG(salary)
                FROM employees);

# 题目: 查询员工中工资大于本部门平均工资的员工的last_name,salary和其department_id。
# 方式1: 使用相关子查询
SELECT last_name, last_name, department_id
FROM employees e1
WHERE salary > (SELECT AVG(salary)
                FROM employees e2
                WHERE department_id = e1.department_id);

# 方式2: 在FROM中声明子查询
SELECT e.last_name, e.salary, e.department_id
FROM employees e,
     (SELECT department_id, AVG(salary) avg_sal
      FROM employees
      GROUP BY department_id) t_dept_avg_sal
WHERE e.department_id = t_dept_avg_sal.department_id
  AND e.salary > t_dept_avg_sal.avg_sal;

# 在ORDER BY中使用子查询:
# 题目: 查询员工的id,salary,按照department_name排序。
SELECT employee_id, salary
FROM employees e
ORDER BY (SELECT d.department_name
          FROM departments d
          WHERE d.department_id = e.department_id) DESC;

# 结论: 在SELECT中，除了GROUP BY和LIMIT之外，其它位置都可以声明子查询！
/*
SELECT ..., ..., ...(存在聚合函数)
FROM ... (LEFT / RIGHT) JOIN ... ON 多表的连接条件
(LEFT / RIGHT) JOIN ... ON ...
WHERE 不包含聚合函数的过滤条件
GROUP BY ..., ...
HAVING 包含聚合函数的过滤条件
ORDER BY ..., ... (ASC / DESC)
LIMIT ..., ...
 */

# 题目：若employees表中employee_id与job_history表中employee_id相同的数目不小于2，
# 输出这些相同id的员工的employee_id,last_name和其job_id。
SELECT *
FROM job_history;

SELECT employee_id, last_name, job_id
FROM employees e
WHERE 2 <= (SELECT COUNT(*)
            FROM job_history j
            WHERE e.employee_id = j.employee_id);
```

### 6.2 EXISTS与NOT EXISTS关键字

```mysql
# 题目：查询公司管理者的employee_id，last_name，job_id，department_id信息。
# 方式1: 自连接
SELECT DISTINCT mgr.employee_id, mgr.last_name, mgr.job_id, mgr.department_id
FROM employees emp
         JOIN employees mgr
              ON emp.manager_id = mgr.employee_id;

# 方式2: 子查询
SELECT employee_id, last_name, job_id, department_id
FROM employees
WHERE employee_id IN (SELECT DISTINCT manager_id
                      FROM employees);

# 方式3: 使用EXISTS
SELECT employee_id, last_name, job_id, department_id
FROM employees e1
WHERE EXISTS(SELECT *
             FROM employees e2
             WHERE e1.employee_id = e2.manager_id);

# 题目：查询departments表中，不存在于employees表中的部门的department_id和department_name。
# 方式1: 使用外连接
SELECT d.department_id, d.department_name
FROM employees e
         RIGHT JOIN departments d
                    ON e.department_id = d.department_id
WHERE e.department_id IS NULL;

# 方式2: 使用NOT EXISTS
SELECT department_id, department_name
FROM departments d
WHERE NOT EXISTS(SELECT *
                 FROM employees e
                 WHERE e.department_id = d.department_id);
```

> 47 第9章 子查询 课后练习1

```mysql
# 1. 查询和Zlotkey相同部门的员工姓名和工资
SELECT last_name, salary
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM employees
                        WHERE last_name = 'Zlotkey');

# 2. 查询工资比公司平均工资高的员工的员工号，姓名和工资。
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary)
                FROM employees);

# 3. 选择工资大于所有JOB_ID = 'SA_MAN'的员工的工资的员工的last_name, job_id, salary
SELECT last_name, job_id, salary
FROM employees
WHERE salary > ALL (SELECT salary
                    FROM employees
                    WHERE job_id = 'SA_MAN');

# 4. 查询和姓名中包含字母u的员工在相同部门的员工的员工号和姓名
SELECT employee_id, last_name
FROM employees
WHERE department_id IN (SELECT DISTINCT department_id
                        FROM employees
                        WHERE last_name LIKE '%u%');

# 5. 查询在部门的location_id为1700的部门工作的员工的员工号
SELECT employee_id
FROM employees
WHERE department_id IN (SELECT department_id
                        FROM departments
                        WHERE location_id = 1700);

# 6. 查询管理者是King的员工姓名和工资
SELECT last_name, salary
FROM employees
WHERE manager_id IN (SELECT employee_id
                     FROM employees
                     WHERE last_name = 'King');

# 7. 查询工资最低的员工信息: last_name, salary
SELECT last_name, salary
FROM employees
WHERE salary = (SELECT MIN(salary)
                FROM employees);

# 8. 查询平均工资最低的部门信息
# 方式1:
SELECT *
FROM departments
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) = (SELECT MIN(avg_sal)
                                             FROM (SELECT AVG(salary) avg_sal
                                                   FROM employees
                                                   GROUP BY department_id) tbL_avg_sal));

# 方式2:
SELECT *
FROM departments
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) <= ALL (SELECT AVG(salary)
                                                  FROM employees
                                                  GROUP BY department_id));

# 方式3: LIMIT
SELECT *
FROM departments
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) = (SELECT AVG(salary) avg_sal
                                             FROM employees
                                             GROUP BY department_id
                                             ORDER BY avg_sal ASC
                                             LIMIT 1));

# 方式4: LIMIT
SELECT d.*
FROM departments d
         JOIN (SELECT department_id, AVG(salary) avg_sal
               FROM employees
               GROUP BY department_id
               ORDER BY avg_sal ASC
               LIMIT 0,1) t_dept_avg_sal
              ON d.department_id = t_dept_avg_sal.department_id;

# 9. 查询平均工资最低的部门信息和该部门的平均工资（相关子查询）
# 方式1:
SELECT d.*, (SELECT AVG(salary) FROM employees e WHERE e.department_id = d.department_id) avg_sal
FROM departments d
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) = (SELECT MIN(avg_sal)
                                             FROM (SELECT AVG(salary) avg_sal
                                                   FROM employees
                                                   GROUP BY department_id) tbL_avg_sal));

# 方式2:
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id) avg_sal
FROM departments d
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) <= ALL (SELECT AVG(salary)
                                                  FROM employees
                                                  GROUP BY department_id));

# 方式3: LIMIT
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id) avg_sal
FROM departments d
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING AVG(salary) = (SELECT AVG(salary) avg_sal
                                             FROM employees
                                             GROUP BY department_id
                                             ORDER BY avg_sal ASC
                                             LIMIT 1));

# 方式4: LIMIT
SELECT d.*, (SELECT AVG(salary) FROM employees WHERE department_id = d.department_id) avg_sal
FROM departments d
         JOIN (SELECT department_id, AVG(salary) avg_sal
               FROM employees
               GROUP BY department_id
               ORDER BY avg_sal ASC
               LIMIT 0,1) t_dept_avg_sal
              ON d.department_id = t_dept_avg_sal.department_id;

```

> 48 第9章 子查询 课后练习2

```mysql
# 10. 查询平均工资最高的 job 信息
# 方式1:
SELECT *
FROM jobs
WHERE job_id = (SELECT job_id
                FROM employees
                GROUP BY job_id
                HAVING AVG(salary) = (SELECT MAX(avg_sal)
                                      FROM (SELECT AVG(salary) avg_sal
                                            FROM employees
                                            GROUP BY job_id) t_job_avg_sal));

# 方式2:
SELECT *
FROM jobs
WHERE job_id = (SELECT job_id
                FROM employees
                GROUP BY job_id
                HAVING AVG(salary) >= ALL (SELECT AVG(salary)
                                           FROM employees
                                           GROUP BY job_id));

# 方式3: LIMIT
SELECT *
FROM jobs
WHERE job_id = (SELECT job_id
                FROM employees
                GROUP BY job_id
                HAVING AVG(salary) = (SELECT AVG(salary) avg_sal
                                      FROM employees
                                      GROUP BY job_id
                                      ORDER BY avg_sal DESC
                                      LIMIT 1));

# 方式4: LIMIT
SELECT j.*
FROM jobs j,
     (SELECT job_id, AVG(salary) avg_sal
      FROM employees
      GROUP BY job_id
      ORDER BY avg_sal DESC
      LIMIT 1) t_job_avg_sal
WHERE j.job_id = t_job_avg_sal.job_id;

# 11. 查询平均工资高于公司平均工资的部门有哪些?
SELECT department_id
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > (SELECT AVG(salary) FROM employees);

# 12. 查询出公司中所有 manager 的详细信息
# 方式1: 自连接
SELECT DISTINCT mgr.employee_id, mgr.last_name, mgr.job_id, mgr.department_id
FROM employees emp
         JOIN employees mgr
              ON emp.manager_id = mgr.employee_id;

# 方式2: 子查询
SELECT employee_id, last_name, job_id, department_id
FROM employees
WHERE employee_id IN (SELECT DISTINCT manager_id
                      FROM employees);

# 方式3: 使用EXISTS
SELECT employee_id, last_name, job_id, department_id
FROM employees e1
WHERE EXISTS(SELECT *
             FROM employees e2
             WHERE e1.employee_id = e2.manager_id);

# 13. 各个部门中 最高工资中最低的那个部门的 最低工资是多少?
# 方式1:
SELECT MIN(salary)
FROM employees
WHERE department_id =
      (SELECT department_id
       FROM employees
       GROUP BY department_id
       HAVING MAX(salary) = (SELECT MIN(max_sal)
                             FROM (SELECT MAX(salary) max_sal
                                   FROM employees
                                   GROUP BY department_id) t_dept_max_sal));

# 方式2:
SELECT MIN(salary)
FROM employees
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING MAX(salary) <=
                                  ALL (SELECT MAX(salary)
                                       FROM employees
                                       GROUP BY department_id));

# 方式3: LIMIT
SELECT MIN(salary)
FROM employees
WHERE department_id = (SELECT department_id
                       FROM employees
                       GROUP BY department_id
                       HAVING MAX(salary) = (SELECT MAX(salary) max_sal
                                             FROM employees
                                             GROUP BY department_id
                                             ORDER BY max_sal
                                             LIMIT 0, 1));

# 方式4: LIMIT
SELECT MIN(e.salary)
FROM employees e
         JOIN
     (SELECT department_id, MAX(salary) max_sal
      FROM employees
      GROUP BY department_id
      ORDER BY max_sal ASC
      LIMIT 1) t_dept_max_sal
WHERE e.department_id = t_dept_max_sal.department_id;

# 14. 查询平均工资最高的部门的 manager 的详细信息: last_name, department_id, email, salary
# 方式1:
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id = ANY (SELECT DISTINCT manager_id
                         FROM employees
                         WHERE department_id = (SELECT department_id
                                                FROM employees
                                                GROUP BY department_id
                                                HAVING AVG(salary) = (SELECT MAX(avg_sal)
                                                                      FROM (SELECT AVG(salary) avg_sal
                                                                            FROM employees
                                                                            GROUP BY department_id) t_dept_avg_sal)));

# 方式2:
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id = ANY (SELECT DISTINCT manager_id
                         FROM employees
                         WHERE department_id = (SELECT department_id
                                                FROM employees
                                                GROUP BY department_id
                                                HAVING AVG(salary) >= ALL (SELECT AVG(salary)
                                                                           FROM employees
                                                                           GROUP BY department_id)));

# 方式3:
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id IN (SELECT DISTINCT manager_id
                      FROM employees e,
                           (SELECT department_id, AVG(salary) avg_sal
                            FROM employees
                            GROUP BY department_id
                            ORDER BY avg_sal DESC
                            LIMIT 1) t_dept_avg_sal
                      WHERE e.department_id = t_dept_avg_sal.department_id);


# 15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号
# 方式1:
SELECT department_id
FROM departments
WHERE department_id NOT IN (SELECT DISTINCT department_id
                            FROM employees
                            WHERE job_id = 'ST_CLERK');

# 方式2:
SELECT department_id
FROM departments d
WHERE NOT EXISTS (SELECT * FROM employees WHERE job_id = 'ST_CLERK' AND department_id = d.department_id);

# 16. 选择所有没有管理者的员工的last_name
# 方式1: NOT EXISTS
SELECT last_name
FROM employees emp
WHERE NOT EXISTS (SELECT * FROM employees mgr WHERE emp.manager_id = mgr.employee_id);

# 方式2: IN
SELECT last_name
FROM employees
WHERE employee_id IN (SELECT employee_id
                      FROM employees
                      WHERE manager_id IS NULL);


# 17. 查询员工号、姓名、雇用时间、工资，其中员工的管理者为'De Haan'
# 方式1: EXISTS
SELECT employee_id, last_name, hire_date, salary
FROM employees emp
WHERE EXISTS(SELECT * FROM employees mgr WHERE emp.manager_id = mgr.employee_id AND mgr.last_name = 'De Haan');

# 方式2: IN
SELECT employee_id, last_name, hire_date, salary
FROM employees
WHERE manager_id IN (SELECT employee_id
                     FROM employees
                     WHERE last_name = 'De Haan');

# 18. 查询各部门中工资比本部门平均工资高的员工的员工号, 姓名和工资(相关子查询)
# 方式1: 相关子查询
SELECT employee_id, last_name, salary
FROM employees e1
WHERE salary > (SELECT AVG(salary)
                FROM employees e2
                WHERE e2.department_id = e1.department_id);

# 方式2: 多表连接
SELECT e.employee_id, e.last_name, e.salary
FROM employees e,
     (SELECT department_id, AVG(salary) avg_sal
      FROM employees
      GROUP BY department_id) tbl_avg_sal
WHERE e.department_id = tbl_avg_sal.department_id
  AND e.salary > tbl_avg_sal.avg_sal;

# 19. 查询每个部门下的部门人数大于5的部门名称(相关子查询)
# 方式1: 相关子查询`
SELECT department_name
FROM departments d
WHERE 5 < (SELECT COUNT(*) FROM employees e WHERE e.department_id = d.department_id);

# 方式2: IN
SELECT department_name
FROM departments
WHERE department_id IN (SELECT department_id
                        FROM employees
                        GROUP BY department_id
                        HAVING COUNT(*) > 5);

# 20. 查询每个国家下的部门个数大于2的国家编号(相关子查询)
SELECT country_id
FROM locations l
WHERE 2 < (SELECT COUNT(*)
           FROM departments d
           WHERE l.location_id = d.location_id);

/*
子查询的编写技巧(或步骤): 1️⃣从里往外写 2️⃣从外往里写

如何选择?
1️⃣如果子查询相对较简单，建议从外往里写。一旦子查询结构较复杂，则建议从里往外写。
2️⃣如果是相关子查询的话，通常都是从外往里写。
*/
```

