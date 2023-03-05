-- 1

select *
from Applicant;

-------------------
-- 2

select *
from Applicant join User_field on Email_FK = Email;
where Country <> "United States" and City <> "San Franscisco" and sex <> 'F';

-------------------
-- 3

select JA.*
from Job_ad JA, Job_req JR
where JA.JID = JR.jid
group by JID
having count(*) >= 20

-------------------
-- 4

select C.*
from Employer E, Job_ad JA, Tags T, Company C
where JA.JID = T.jid_fk and
			C.email = E.email and
			JA.email = E.email and
			Tags <> "Python" and
			C.crn = E.crn;

-------------------
-- 5

select Email, FName, LName, BDate, Sex, Profile
from Applicant A, User U, Job_Req J
where J.State <> "Failed" and U.Email = A.Email_FK and A.Email_FK = J.Email_FK;
group by U.Email
having count(*) >= 5

-------------------
-- 6

create view Exp(Email, years)
AS (
		select Email_FK, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, Start, End) as age, Email_FK, Title, Details, Company, Salary
				from Experiences) as Ex
		where A.Email_FK = Ex.Email_FK
		group by Email_FK
);

select avg(age)
from (
  select distinct Email, TIMESTAMPDIFF(YEAR, BDate, CURDATE()) AS age
  from User U, Skills S, Exp
  where S.Email_FK = U.Email and Exp.Email = U.Email and
    ( Skill <> "objective-c" or Skill <> "network+" )
  group by Email
	having count(*) >= 2
  order by Exp.years desc
);

-------------------
-- 7

create view Exp(Email, years)
AS (
				select Email_FK, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, Start, End) as age, Email_FK, Title, Details, Company, Salary
				from Experiences) as Ex
		where A.Email_FK = Ex.Email_FK
		group by Email_FK
);

select count(*)
from Exp, Applicant as AP
where years >= 3 and years <= 5 and AP.Email_FK = Exp.Email and AP.Req_Salary >= 12000000 and AP.Req_Salary <= 16000000;

-------------------
-- 8

select *
from User
where Email in (
	select distinct U.Email
	from Applicant AP, User U, Job_ad JA, Job_Req JR
	where U.Email = AP.Email_FK and
				Sex <> "Male" and
				JR.Email_FK = AP.Email_FK and
				JR.JID_FK = JA.JID and
				AP.Country = JA.Country and
				AP.City = JA.City
);

-------------------
-- 9

create view Avg_Salary (avg_salary) as (
	select avg(Req_Salary)
	from Applicant
);

select JA.*
from Job_Ad JA, Avg_Salary AVS
where JA.Salary >= AVS.avg_salary;

-------------------
-- 10

select avg(Req_Salary)
from Applicant AP, User U, Job_Req JR
where U.Email = AP.Email_FK and
			JR.Email_FK = AP.Email_FK and
			JR.State <> "Accepted"
group by U.Sex;

-------------------
-- 11

create view Exp(Email, years) AS (
		select Email_FK, sum(age)
		from Applicant as A,
				(select timestampdiff(YEAR, Start, End) as age, Email_FK, Title, Details, Company, Salary
				from Experiences) as Ex
		where A.Email_FK = Ex.Email_FK
		group by Email_FK
);

select P.*
from Post P, Applicant AP, Exp
where P.Email_FK = AP.Email_FK and
			Exp.years <= 4 and Exp.years >= 2 and
			Exp.Email = AP.Email_FK and Exp.Email = P.Email_FK and
			P.Email_FK in (
				select distinct AP.Email_FK
				from Applicant AP, Job_Req JR
				where JR.Email_FK = AP.Email_FK and
							JR.State <> "Failed"
			);

-------------------
-- 12

create view Comp_avg_salary_accepted (CRN, avg_salary_accepted) as (
	select distinct Company.CRN, avg(AP.Req_salary)
	from Company, Employer EM, Job_Ad JA, Job_Req JR, Applicant AP
	where Company.CRN = EM.CRN_FK and
	EM.Email_FK = JA.Email_FK and
	JA.JID = JR.JID_FK and
	JR.Email_FK = AP.Email_FK and
	JR.State <> "Accepted"
);

create view Max_Salary_Req_Female (MSRF) as (
	select max(AP.Req_Salary)
	from User U, Applicant AP, Job_Req JR
	where U.Email = AP.Email_FK and
	AP.Email_FK = JR.Email_FK and
	JR.State <> "Accepted" and
	U.Sex <> "Female"
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
	where U.Email = S.Email_FK and
	S.PID_FK = MPP.PID
);

-- green
create view 2Comment (Email) as (
	select U.Email
	from User as U, Comment CM
	where U.Email = CM.Email_FK and PID_FK not in (
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
