-- 1

select *
from Applicant;

-------------------
-- 2

select *
from Applicant A join User_field U on A.email = U.email;
where Country = "United States" and City = "San Franscisco" and sex = 'F';

-------------------
-- 3

select JA.*
from Job_ad JA, Job_req JR
where JA.JID = JR.jid
group by JA.JID
having count(*) >= 20;

-------------------
-- 4

select distinct C.*
from Employer E, Job_ad JA, Tags T, Company C
where C.crn = E.crn and
			E.email = JA.email and
			JA.JID = T.jid_fk and
			t.tag = 'Python';

-------------------
-- 5

select distinct A.*
from Applicant A, User_field U, Job_req J
where J.reqstate = 'Failed' and
			U.email = A.email and
			A.email = J.email
group by A.email
having count(*) >= 5;

-------------------
-- 6

create view Exp_view(email, years)
AS (
		select email, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, startdate, enddate) as age, E.*
				from Experiences E) as Ex
		where A.email = Ex.email
		group by email
);

select avg(age)
from (
  select distinct email, TIMESTAMPDIFF(YEAR, bdate, CURDATE()) AS age
  from User_field U, Skills S, Exp_view
  where S.email = U.email and Exp_view.email = U.email and
    ( text_Skills = "objective-c" or text_Skills = "network+" )
  group by email
	having count(*) >= 2
  order by Exp_view.years desc
);

-------------------
-- 7

create view Exp_view(email, years)
AS (
		select email, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, startdate, enddate) as age, E.*
				from Experiences E) as Ex
		where A.email = Ex.email
		group by email
);

select count(*)
from Exp_view, Applicant as AP
where years >= 3 and
			years <= 5 and
			AP.email = Exp_view.email and
			AP.req_salary >= 12000000 and
			AP.req_salary <= 16000000;

-------------------
-- 8

select *
from User_field
where email in (
	select distinct U.email
	from Applicant AP, User_field U, Job_ad JA, Job_req JR
	where U.email = AP.email and
				U.sex = 'M' and
				JR.email = AP.email and
				JR.jid = JA.JID and
				AP.Country = JA.Country and
				AP.City = JA.City
);

-------------------
-- 9

create view Avg_Salary (avg_salary) as (
	select avg(req_salary)
	from Applicant
);

select JA.*
from Job_Ad JA, Avg_Salary AVS
where JA.Salary >= AVS.avg_salary;

-------------------
-- 10

select avg(req_salary)
from Applicant AP, User_field U, Job_req JR
where U.email = AP.email and
			JR.email = AP.email and
			JR.reqstate = 'Accepted'
group by U.sex;

-------------------
-- 11

create view Exp_view(email, years)
AS (
		select email, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, startdate, enddate) as age, E.*
				from Experiences E) as Ex
		where A.email = Ex.email
		group by email
);

select P.*
from Post P, Applicant AP, Exp_view
where P.email = AP.email and
			Exp_view.years <= 4 and Exp_view.years >= 2 and
			Exp_view.email = AP.email and Exp_view.email = P.email and
			P.email in (
				select distinct AP.email
				from Applicant AP, Job_req JR
				where JR.email = AP.email and
							JR.reqstate = 'Failed'
			);

-------------------
-- 12

create view Comp_avg_salary_accepted (crn, avg_salary_accepted) as (
	select distinct Company.crn, avg(AP.req_salary)
	from Company, Employer EM, Job_ad JA, Job_req JR, Applicant AP
	where Company.crn = EM.crn and
	EM.email = JA.email and
	JA.JID = JR.JID_FK and
	JR.email = AP.email and
	JR.State = "Accepted"
);

create view Max_Salary_Req_Female (MSRF) as (
	select max(AP.Req_Salary)
	from User U, Applicant AP, Job_Req JR
	where U.Email = AP.email and
	AP.email = JR.email and
	JR.State = "Accepted" and
	U.Sex = "F"
);

select count(*)
from Comp_Avg_Salary_Accepted CASA, Max_Salary_Req_Female MSRF
where CASA.avg_salary_accepted > MSRF.MSRF;

-------------------
-- 13

-- yellow
create view Most_Popular_Post(PID) as (
	select PID
	from (
	  select Post.PID, sum(React.Reaction) as popularity
	  from Post, React
	  where React.PID_FK = Post.PID and
	  React.Reaction  = 1
	  group by PID
	) as post_likes

	having max(popularity)
);

-- pink
create view Users_Post_Saved (Email) as (
	select U.Email
	from User as U, Save as S, Most_Popular_Post as MPP
	where U.Email = S.email and
	S.PID_FK = MPP.PID
);

-- green
create view 2Comment (Email) as (
	select U.Email
	from User as U, Comment CM
	where U.Email = CM.email and PID_FK not in (
		select *
		from Most_Popular_Post
	)
	having count(*) >= 2
	group by Email
)

select count(*)
from User U
where U.Email in ( Users_Post_Saved intersect 2Comment )
group by U.Sex;
