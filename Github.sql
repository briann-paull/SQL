use test;

--Using CTE's
go
;with step1 as
(Select

-- using Concat
concat(e.FirstName,'',e.LastName) as FullName, 
e.ADEmail as email,
e.EmpID as ID,
e.Current_Employee_rating as Rating,
e.ExitDate as ExitDate,
t.Training_Cost,
t.Trainer,
r.Desired_Salary,
r.Years_of_Experience as exp

--using Joins
from emp e
left join training t
on e.EmpID=t.Employee_ID
left join recruitment r
on e.EmpID=r.Applicant_ID
),
step2 as
( select * from step1 where ExitDate is not null and Rating>3
),
step3 as
( Select 

--using REGEXP
REGEXP_REPLACE(FullName,'([a-z])([A-Z])','\1 \2') as name,
email,
Rating,
ExitDate,
Training_Cost,

--using cast for changing datatype
cast(desired_salary as INT) as salary,

--using left and Charindex
left(Trainer,CHARINDEX(' ',Trainer)-1) as Teacher  from step2
),
step4 as
( select 
name,
email,
Rating,
Teacher,
salary,
--using of dense _rank 
Dense_rank() over (Order By Teacher) As TeacherID,
case 
when salary>90000 then 'Type1'
when salary>40000 then 'Type2'
when salary>20000 then 'type3'
end as Bonus
from step3
)

--table creation from the query
select *
into testing from 
step4;

--Top5
select top 5* from testing order by salary desc;
--Offset
select * from testing order by salary desc offset 2 rows fetch next 3 rows only;
--In function
select * from testing where teacher in ('Luis','Aaron');
--Between
select name from testing where salary between 80000 and 85000 order by salary desc offset 0 rows fetch next 3 rows only;
--like function
select name,Teacher,bonus from testing where name like 'a%a';
--aggregrates
select
avg(salary) as avg_sal,
min(salary) as min_sal,
max(salary) as max_sal,
sum(salary) as sum_sal,
count(distinct name) as count_name from testing;

--group by
select bonus,avg(salary) from testing group by Bonus;
--having
select teacher,avg(salary) from testing group by Teacher having avg(salary)>80000;
--window
select name,salary, max(salary) over() salary from testing;
--nested query
select * from testing where salary >(select avg(salary) from testing);

--table creation
use test;
CREATE TABLE NEmployees
(
    EmpID INT,
    Name VARCHAR(50),
    Department VARCHAR(30),
    City VARCHAR(30),
    Salary INT,
    JoiningDate DATE
);
--insert values in table
INSERT INTO NEmployees VALUES
(1,'John','IT','Mumbai',50000,'2022-01-10'),
(2,'Alice','HR','Delhi',40000,'2021-06-15'),
(3,'Bob','IT','Mumbai',55000,'2020-02-20'),
(4,'David','Finance','Delhi',60000,'2023-01-11'),
(5,'Eva','IT','Bangalore',70000,'2019-04-17'),
(6,'Mike','Finance','Mumbai',45000,'2020-08-18'),
(7,'Sara','HR','Delhi',42000,'2022-05-05');

--Partition example again
SELECT *,
max(Salary) OVER(partition by City order by Salary desc) AS max_sal
FROM NEmployees;

--Lag Window
select *,
lag(salary) over(order by salary) as lag_sal
from NEmployees ;

--lead Window
select 
*,
lead(salary) over(order by salary) as lead_sal
from NEmployees;

--First_Value 
SELECT *,
FIRST_Value(salary) over(partition by department order by salary desc) as First
from NEmployees;

--Last_Value 
select *,
Last_Value(salary) over(partition by department order by salary rows between unbounded preceding and unbounded following) as l_test
from NEmployees;

--Ntile

select *,
NTILE(2) over(order by salary) as Ntile_test
from NEmployees;

--Try and catch

begin try

select 10/0;
end try
begin catch
select 'tried_test' as message;
end catch;

--Pyramid 
use test;
declare @i int =1;
while @i<=20
begin
print replicate('*',@i);
set @i=@i+1;
end;
