--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--


ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:5b4db28c1cce0063294ea639d3157a44:aa0295d50d5e266a40472eafcb717b434543ba85eb796f348402efa42a990197';






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Homebrew)
-- Dumped by pg_dump version 14.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Homebrew)
-- Dumped by pg_dump version 14.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: delete_old_job_ad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_old_job_ad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM Job_ad WHERE JID = OLD.JID;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.delete_old_job_ad() OWNER TO postgres;

--
-- Name: remove_old_job_ad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_old_job_ad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	  DELETE FROM Job_ad WHERE jdate < NOW() - INTERVAL '1 year';
		  RETURN NULL;
		END;
		$$;


ALTER FUNCTION public.remove_old_job_ad() OWNER TO postgres;

--
-- Name: remove_user_if_dislikes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_user_if_dislikes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	total_reacts INTEGER;
	dislikes INTEGER;
	dislike_percentage NUMERIC;
BEGIN
		SELECT COUNT(*) INTO total_reacts FROM React WHERE email = NEW.email;
		SELECT COUNT(*) INTO dislikes FROM React WHERE email = NEW.email AND reaction = 'Dislike';
		dislike_percentage = (dislikes::NUMERIC / total_reacts::NUMERIC) * 100;

		IF total_reacts > 100 AND dislike_percentage > 95 THEN
			DELETE FROM User_field WHERE email = NEW.email;
		END IF;

		RETURN NEW;
END;
$$;


ALTER FUNCTION public.remove_user_if_dislikes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applicant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applicant (
    email character varying(255) NOT NULL,
    country character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    app_address character varying(100),
    req_salary bigint
);


ALTER TABLE public.applicant OWNER TO postgres;

--
-- Name: avg_salary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.avg_salary AS
 SELECT avg(applicant.req_salary) AS avg_salary
   FROM public.applicant;


ALTER TABLE public.avg_salary OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    cname character varying(50) NOT NULL,
    noe integer NOT NULL,
    crn character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    country character varying(20),
    city character varying(20),
    com_address character varying(50)
);


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: employer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employer (
    email character varying(255) NOT NULL,
    crn character varying(20) NOT NULL,
    "position" character varying(20)
);


ALTER TABLE public.employer OWNER TO postgres;

--
-- Name: job_ad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad (
    jid integer NOT NULL,
    jdate date NOT NULL,
    title character varying(50) NOT NULL,
    visibility boolean NOT NULL,
    jstate character varying(10),
    email character varying(255) NOT NULL,
    country character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    app_address character varying(100) NOT NULL,
    job_description text,
    salary bigint
);


ALTER TABLE public.job_ad OWNER TO postgres;

--
-- Name: job_req; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_req (
    jid integer NOT NULL,
    email character varying(255) NOT NULL,
    reqstate character varying(10) NOT NULL,
    reqdate date NOT NULL,
    reqtext character varying(255),
    reqresume text
);


ALTER TABLE public.job_req OWNER TO postgres;

--
-- Name: comp_avg_salary_accepted; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.comp_avg_salary_accepted AS
 SELECT DISTINCT company.crn,
    avg(ap.req_salary) AS avg_salary_accepted
   FROM public.company,
    public.employer em,
    public.job_ad ja,
    public.job_req jr,
    public.applicant ap
  WHERE (((company.crn)::text = (em.crn)::text) AND ((em.email)::text = (ja.email)::text) AND (ja.jid = jr.jid) AND ((jr.email)::text = (ap.email)::text) AND ((jr.reqstate)::text = 'approved'::text))
  GROUP BY company.crn;


ALTER TABLE public.comp_avg_salary_accepted OWNER TO postgres;

--
-- Name: experience; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experience (
    email character varying(255) NOT NULL,
    title character varying(50) NOT NULL,
    details character varying(255) NOT NULL,
    company character varying(20) NOT NULL,
    salary bigint NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE public.experience OWNER TO postgres;

--
-- Name: exp_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.exp_view AS
 SELECT a.email,
    sum(ex.age) AS years
   FROM public.applicant a,
    ( SELECT EXTRACT(year FROM age((e.enddate)::timestamp with time zone, (e.startdate)::timestamp with time zone)) AS age,
            e.email,
            e.title,
            e.details,
            e.company,
            e.salary,
            e.startdate,
            e.enddate
           FROM public.experience e) ex
  WHERE ((a.email)::text = (ex.email)::text)
  GROUP BY a.email;


ALTER TABLE public.exp_view OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    url_image character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_jid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_jid_seq OWNER TO postgres;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_jid_seq OWNED BY public.job_ad.jid;


--
-- Name: user_field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_field (
    fname character varying(50) NOT NULL,
    lname character varying(50) NOT NULL,
    bdate date NOT NULL,
    sex character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pic_profile character varying(255)
);


ALTER TABLE public.user_field OWNER TO postgres;

--
-- Name: max_salary_req_female; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.max_salary_req_female AS
 SELECT max(ap.req_salary) AS msrf
   FROM public.user_field u,
    public.applicant ap,
    public.job_req jr
  WHERE (((u.email)::text = (ap.email)::text) AND ((ap.email)::text = (jr.email)::text) AND ((jr.reqstate)::text = 'approved'::text) AND (u.sex = 'F'::bpchar));


ALTER TABLE public.max_salary_req_female OWNER TO postgres;

--
-- Name: react; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.react (
    reaction character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL,
    reaction_num integer
);


ALTER TABLE public.react OWNER TO postgres;

--
-- Name: most_popular_post; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.most_popular_post AS
 SELECT post_likes.pid
   FROM ( SELECT react.pid_fk AS pid,
            sum(react.reaction_num) AS popularity
           FROM public.react
          GROUP BY react.pid_fk
          ORDER BY (sum(react.reaction_num)) DESC) post_likes
  ORDER BY post_likes.popularity DESC
 LIMIT 1;


ALTER TABLE public.most_popular_post OWNER TO postgres;

--
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post (
    pid integer NOT NULL,
    ptext text,
    pstate character varying(10) NOT NULL,
    pdate date NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.post OWNER TO postgres;

--
-- Name: post_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_comment (
    cid integer NOT NULL,
    ctext character varying(255) NOT NULL,
    cdate date NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL,
    cidfk integer
);


ALTER TABLE public.post_comment OWNER TO postgres;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.post_comment_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_comment_cid_seq OWNER TO postgres;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.post_comment_cid_seq OWNED BY public.post_comment.cid;


--
-- Name: post_pid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.post_pid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_pid_seq OWNER TO postgres;

--
-- Name: post_pid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.post_pid_seq OWNED BY public.post.pid;


--
-- Name: save_post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.save_post (
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.save_post OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    text_skills character varying(100) NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    tag character varying(50) NOT NULL,
    jid_fk integer NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: two_comment; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.two_comment AS
 SELECT u.email
   FROM public.user_field u,
    public.post_comment cm
  WHERE (((u.email)::text = (cm.email)::text) AND (NOT (cm.pid_fk IN ( SELECT most_popular_post.pid
           FROM public.most_popular_post))))
  GROUP BY u.email
 HAVING (count(*) >= 2);


ALTER TABLE public.two_comment OWNER TO postgres;

--
-- Name: users_post_saved; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.users_post_saved AS
 SELECT u.email
   FROM public.user_field u,
    public.save_post s,
    public.most_popular_post mpp
  WHERE (((u.email)::text = (s.email)::text) AND (s.pid_fk = mpp.pid));


ALTER TABLE public.users_post_saved OWNER TO postgres;

--
-- Name: job_ad jid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad ALTER COLUMN jid SET DEFAULT nextval('public.job_ad_jid_seq'::regclass);


--
-- Name: post pid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post ALTER COLUMN pid SET DEFAULT nextval('public.post_pid_seq'::regclass);


--
-- Name: post_comment cid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment ALTER COLUMN cid SET DEFAULT nextval('public.post_comment_cid_seq'::regclass);


--
-- Data for Name: applicant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applicant (email, country, city, app_address, req_salary) FROM stdin;
amartin@gmail.com	USA	New York	123 Main St	50000
esmith@hotmail.com	Canada	Toronto	456 Elm St	60000
njohnson@yahoo.com	USA	Los Angeles	789 Oak St	55000
odavis@gmail.com	Australia	Sydney	\N	70000
lwilson@hotmail.com	USA	Chicago	456 Pine St	65000
smoore@yahoo.com	Canada	Vancouver	\N	55000
ebrown@gmail.com	USA	San Francisco	789 Maple St	75000
ilee@hotmail.com	Australia	Melbourne	123 Cherry St	60000
mgarcia@yahoo.com	USA	Houston	456 Cedar St	55000
mrodriguez@gmail.com	Canada	Montreal	\N	70000
pedram.pooya.2010@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2009@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2008@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2007@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2006@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2005@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2004@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2003@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2002@gmail.com	Iran	Qom	12 Esteghlal	2000000
pedram.pooya.2001@gmail.com	Iran	Qom	12 Esteghlal	2000000
mm.motahari.2001@gmail.com	Iran	Qom	\N	14000000
erfan.hamidi@gmail.com	Iran	Hamadan	\N	15340000
erfan.bamdadi@gmail.com	Iran	Sanandaj	\N	14349000
\.


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company (cname, noe, crn, email, country, city, com_address) FROM stdin;
Acme Corp	500	CRN123	johndoe@example.com	USA	New York	123 Main St
Globex Inc	1000	CRN456	janedoe@example.com	USA	Los Angeles	456 Oak Ave
Initech LLC	250	CRN789	bobsmith@example.com	USA	Chicago	789 Elm St
Wayne Enterprises	750	CRN987	alicejones@example.com	USA	Gotham City	987 Wayne Manor
Stark Industries	1000	CRN654	davidbrown@example.com	USA	New York	654 Fifth Ave
\.


--
-- Data for Name: employer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employer (email, crn, "position") FROM stdin;
johndoe@example.com	CRN123	CEO
janedoe@example.com	CRN456	CTO
bobsmith@example.com	CRN789	CFO
alicejones@example.com	CRN987	COO
davidbrown@example.com	CRN654	VP of Marketing
\.


--
-- Data for Name: experience; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.experience (email, title, details, company, salary, startdate, enddate) FROM stdin;
amartin@gmail.com	Software Engineer	Developed and maintained software applications	ABC Inc.	75000	2018-01-01	2021-06-30
amartin@gmail.com	Project Manager	Led a team of developers to deliver software projects on time and within budget	XYZ Corp.	85000	2021-07-01	2022-12-31
esmith@hotmail.com	Marketing Manager	Developed and implemented marketing campaigns	ABC Inc.	80000	2019-02-01	2022-05-31
esmith@hotmail.com	Sales Representative	Generated new leads and closed deals	XYZ Corp.	60000	2022-06-01	2023-02-28
njohnson@yahoo.com	Data Analyst	Analyzed data and generated reports	123 Corp.	70000	2020-03-01	2021-12-31
njohnson@yahoo.com	Data Scientist	Built and trained machine learning models	456 Corp.	90000	2022-01-01	2023-03-08
odavis@gmail.com	Senior Developer	Designed and implemented software solutions	ABC Inc.	100000	2017-01-01	2022-03-31
lwilson@hotmail.com	IT Manager	Managed IT infrastructure and systems	XYZ Corp.	90000	2018-04-01	2022-02-28
smoore@yahoo.com	Graphic Designer	Designed marketing materials and websites	ABC Inc.	60000	2020-01-01	2022-12-31
ebrown@gmail.com	Product Manager	Managed the product lifecycle from ideation to launch	XYZ Corp.	95000	2019-06-01	2022-09-30
ilee@hotmail.com	Human Resources Manager	Managed HR functions including recruiting, onboarding, and performance management	ABC Inc.	85000	2021-01-01	2023-03-08
mgarcia@yahoo.com	Financial Analyst	Analyzed financial data and prepared reports for management	XYZ Corp.	70000	2022-02-01	2023-03-08
mrodriguez@gmail.com	Customer Service Representative	Handled customer inquiries and resolved issues	123 Corp.	55000	2021-03-01	2022-11-30
mm.motahari.2001@gmail.com	Wordpress Developer	Driver ==)	Snapp	7000000	2018-03-13	2022-11-29
erfan.hamidi@gmail.com	Django Developer	Aghaaa aaaaali	Digikala	10000000	2012-03-13	2015-11-29
erfan.bamdadi@gmail.com	C++ Developer	Kheiliam Ali	Dade kavan	7000000	2010-03-13	2011-11-29
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (url_image, pid_fk) FROM stdin;
https://example.com/image1.jpg	1
https://example.com/image2.jpg	1
https://example.com/image3.jpg	2
https://example.com/image4.jpg	2
https://example.com/image5.jpg	3
https://example.com/image6.jpg	3
https://example.com/image7.jpg	4
https://example.com/image8.jpg	4
https://example.com/image9.jpg	5
https://example.com/image10.jpg	5
https://example.com/image11.jpg	6
https://example.com/image12.jpg	6
https://example.com/image13.jpg	7
https://example.com/image14.jpg	7
https://example.com/image15.jpg	8
https://example.com/image16.jpg	8
https://example.com/image17.jpg	9
https://example.com/image18.jpg	9
https://example.com/image19.jpg	10
https://example.com/image20.jpg	10
https://example.com/image21.jpg	11
https://example.com/image22.jpg	11
https://example.com/image23.jpg	12
https://example.com/image24.jpg	12
https://example.com/image25.jpg	13
https://example.com/image26.jpg	13
https://example.com/image27.jpg	14
https://example.com/image28.jpg	14
https://example.com/image29.jpg	15
https://example.com/image30.jpg	15
\.


--
-- Data for Name: job_ad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad (jid, jdate, title, visibility, jstate, email, country, city, app_address, job_description, salary) FROM stdin;
8	2022-03-30	Accountant	f	closed	janedoe@example.com	Canada	Toronto	789 Maple St	We are seeking an experienced accountant to join our finance team.	20000000
9	2022-04-15	Web Designer	t	open	janedoe@example.com	UK	London	456 Elm St	We are seeking a talented web designer to help us create engaging and user-friendly websites.	20000000
10	2022-05-01	Sales Representative	t	open	bobsmith@example.com	Australia	Sydney	789 Pine St	We are seeking an energetic and results-driven sales representative to join our team.	20000000
11	2022-05-02	Front-end Developer	t	open	bobsmith@example.com	Australia	Sydney	789 Pine St	We are hiring.	2000000
12	2022-05-03	Back-end Developer	t	open	bobsmith@example.com	Australia	Sydney	789 Pine St	Django.	200000
13	2022-05-04	Driver	t	open	bobsmith@example.com	Australia	Sydney	789 Pine St	We are hiring driver.	20000
14	2022-10-02	DevOps Intern	t	open	johndoe@example.com	Iran	Qom	Blv amin	Intern for devops position	20000
15	2022-10-02	Senior Devops	t	open	johndoe@example.com	USA	New York	Blv amin	Senior Devops engineer	50000
\.


--
-- Data for Name: job_req; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_req (jid, email, reqstate, reqdate, reqtext, reqresume) FROM stdin;
10	ebrown@gmail.com	approved	2022-04-15	I am applying for the Sales Representative position	I have 5 years of sales experience.
10	odavis@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	amartin@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	esmith@hotmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	lwilson@hotmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	smoore@yahoo.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	mgarcia@yahoo.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	mrodriguez@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2010@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2009@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2008@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2007@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2005@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2004@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2003@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2002@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
10	pedram.pooya.2001@gmail.com	pending	2022-03-02	I am applying for job_ad 10	\N
15	amartin@gmail.com	pending	2022-10-03	Im very interested for this position	nothing
15	mm.motahari.2001@gmail.com	pending	2022-10-03	Im very interested for this position	nothing
9	odavis@gmail.com	rejected	2022-03-01	I am interested in the Web Designer position	Here is a link to my portfolio: www.odavisdesigns.com.
12	mgarcia@yahoo.com	rejected	2022-05-15	I am applying for the Back-end Developer position	I have experience with Python and Django.
8	pedram.pooya.2001@gmail.com	rejected	2022-03-02	I am applying for job_ad 6	\N
9	pedram.pooya.2001@gmail.com	rejected	2022-03-02	I am applying for job_ad 6	\N
11	pedram.pooya.2001@gmail.com	rejected	2022-03-02	I am applying for job_ad 6	\N
12	pedram.pooya.2001@gmail.com	rejected	2022-03-02	I am applying for job_ad 6	\N
14	mm.motahari.2001@gmail.com	approved	2022-10-03	Im very interested for this position	nothing
10	pedram.pooya.2006@gmail.com	approved	2022-03-02	I am applying for job_ad 10	\N
11	ilee@hotmail.com	approved	2022-05-01	I am interested in the Front-end Developer position	Here is a link to my GitHub portfolio.
13	mrodriguez@gmail.com	approved	2022-06-01	I am not interested in the Driver position	\N
8	smoore@yahoo.com	approved	2022-04-01	I am interested in the Marketing Specialist position	I have experience in social media marketing.
10	ilee@hotmail.com	rejected	2022-03-02	I am applying for job_ad 10	\N
10	njohnson@yahoo.com	rejected	2022-03-02	I am applying for job_ad 10	\N
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post (pid, ptext, pstate, pdate, email) FROM stdin;
1	Post 1	draft	2022-05-27	johndoe@example.com
2	Post 2	published	2022-10-15	janedoe@example.com
3	Post 3	draft	2022-11-14	bobsmith@example.com
4	Post 4	published	2022-04-17	alicejones@example.com
5	Post 5	draft	2022-05-02	davidbrown@example.com
6	Post 6	draft	2023-01-12	amartin@gmail.com
7	Post 7	published	2022-12-15	esmith@hotmail.com
8	Post 8	published	2022-08-31	njohnson@yahoo.com
9	Post 9	published	2023-02-17	odavis@gmail.com
10	Post 10	draft	2022-04-05	lwilson@hotmail.com
11	Post 11	published	2022-07-04	smoore@yahoo.com
12	Post 12	published	2023-01-26	ebrown@gmail.com
13	Post 13	published	2022-09-14	ilee@hotmail.com
14	Post 14	published	2022-05-07	mgarcia@yahoo.com
15	Post 15	draft	2022-12-18	mrodriguez@gmail.com
16	Post 1	draft	2022-04-11	johndoe@example.com
17	Post 2	published	2022-06-09	janedoe@example.com
18	Post 3	draft	2022-07-01	bobsmith@example.com
19	Post 4	published	2022-11-17	alicejones@example.com
20	Post 5	published	2022-06-08	davidbrown@example.com
21	Post 6	published	2022-03-13	amartin@gmail.com
22	Post 7	draft	2022-12-09	esmith@hotmail.com
23	Post 8	draft	2022-03-13	njohnson@yahoo.com
24	Post 9	draft	2022-07-04	odavis@gmail.com
25	Post 10	draft	2022-09-22	lwilson@hotmail.com
26	Post 11	published	2022-10-12	smoore@yahoo.com
27	Post 12	draft	2023-01-26	ebrown@gmail.com
28	Post 13	draft	2022-05-05	ilee@hotmail.com
29	Post 14	published	2022-11-24	mgarcia@yahoo.com
30	Post 15	draft	2023-01-04	mrodriguez@gmail.com
31	Post 1	published	2022-04-29	johndoe@example.com
32	Post 2	published	2022-07-21	janedoe@example.com
33	Post 3	published	2022-12-22	bobsmith@example.com
34	Post 4	published	2022-10-23	alicejones@example.com
35	Post 5	published	2022-12-10	davidbrown@example.com
36	Post 6	published	2022-10-14	amartin@gmail.com
37	Post 7	published	2022-09-14	esmith@hotmail.com
38	Post 8	published	2022-12-25	njohnson@yahoo.com
39	Post 9	draft	2023-01-11	odavis@gmail.com
40	Post 10	published	2022-04-05	lwilson@hotmail.com
41	Post 11	published	2022-10-25	smoore@yahoo.com
42	Post 12	draft	2022-07-01	ebrown@gmail.com
43	Post 13	published	2022-05-09	ilee@hotmail.com
44	Post 14	draft	2022-03-19	mgarcia@yahoo.com
45	Post 15	published	2022-12-29	mrodriguez@gmail.com
46	Post 1	published	2022-08-11	johndoe@example.com
47	Post 2	published	2022-07-02	janedoe@example.com
48	Post 3	published	2022-10-28	bobsmith@example.com
49	Post 4	published	2022-10-17	alicejones@example.com
50	Post 5	published	2022-06-26	davidbrown@example.com
51	Post 6	published	2022-07-19	amartin@gmail.com
52	Post 7	published	2022-11-10	esmith@hotmail.com
53	Post 8	published	2022-11-12	njohnson@yahoo.com
54	Post 9	published	2022-04-14	odavis@gmail.com
55	Post 10	published	2022-10-13	lwilson@hotmail.com
56	Post 11	published	2022-05-20	smoore@yahoo.com
57	Post 12	published	2022-07-26	ebrown@gmail.com
58	Post 13	published	2022-05-11	ilee@hotmail.com
59	Post 14	published	2022-04-06	mgarcia@yahoo.com
60	Post 15	published	2022-10-25	mrodriguez@gmail.com
61	Post 1	published	2022-07-26	johndoe@example.com
62	Post 2	published	2022-11-18	janedoe@example.com
63	Post 3	published	2022-08-24	bobsmith@example.com
64	Post 4	published	2022-06-28	alicejones@example.com
65	Post 5	published	2022-07-08	davidbrown@example.com
66	Post 6	published	2022-07-12	amartin@gmail.com
67	Post 7	draft	2022-11-17	esmith@hotmail.com
68	Post 8	published	2023-03-03	njohnson@yahoo.com
69	Post 9	draft	2022-09-08	odavis@gmail.com
70	Post 10	published	2022-10-31	lwilson@hotmail.com
71	Post 11	draft	2022-05-31	smoore@yahoo.com
72	Post 12	draft	2022-09-13	ebrown@gmail.com
73	Post 13	published	2022-05-13	ilee@hotmail.com
74	Post 14	draft	2023-01-28	mgarcia@yahoo.com
75	Post 15	published	2022-03-31	mrodriguez@gmail.com
76	Post 1	published	2022-03-22	johndoe@example.com
77	Post 2	published	2023-01-04	janedoe@example.com
78	Post 3	published	2022-08-12	bobsmith@example.com
79	Post 4	published	2022-07-22	alicejones@example.com
80	Post 5	published	2023-01-16	davidbrown@example.com
81	Post 6	published	2022-08-19	amartin@gmail.com
82	Post 7	published	2022-07-05	esmith@hotmail.com
83	Post 8	draft	2022-10-19	njohnson@yahoo.com
84	Post 9	published	2022-07-03	odavis@gmail.com
85	Post 10	published	2022-05-18	lwilson@hotmail.com
86	Post 11	published	2022-07-30	smoore@yahoo.com
87	Post 12	published	2023-01-16	ebrown@gmail.com
88	Post 13	draft	2022-08-23	ilee@hotmail.com
89	Post 14	published	2022-04-02	mgarcia@yahoo.com
90	Post 15	published	2022-09-02	mrodriguez@gmail.com
91	Post 1	published	2022-10-25	johndoe@example.com
92	Post 2	published	2022-10-19	janedoe@example.com
93	Post 3	published	2022-11-18	bobsmith@example.com
94	Post 4	draft	2022-03-18	alicejones@example.com
95	Post 5	published	2023-02-25	davidbrown@example.com
96	Post 6	published	2022-08-08	amartin@gmail.com
97	Post 7	published	2022-07-28	esmith@hotmail.com
98	Post 8	published	2022-10-19	njohnson@yahoo.com
99	Post 9	published	2022-05-26	odavis@gmail.com
100	Post 10	published	2023-01-29	lwilson@hotmail.com
101	Post 11	published	2022-05-15	smoore@yahoo.com
102	Post 12	published	2022-08-29	ebrown@gmail.com
103	Post 13	published	2022-03-18	ilee@hotmail.com
104	Post 14	published	2022-11-30	mgarcia@yahoo.com
105	Post 15	published	2022-07-28	mrodriguez@gmail.com
106	Post 1	published	2022-06-29	johndoe@example.com
107	Post 2	published	2022-07-08	janedoe@example.com
108	Post 3	published	2023-01-11	bobsmith@example.com
109	Post 4	draft	2023-01-24	alicejones@example.com
110	Post 5	published	2022-03-31	davidbrown@example.com
111	Post 6	published	2022-06-17	amartin@gmail.com
112	Post 7	published	2022-12-24	esmith@hotmail.com
113	Post 8	published	2023-01-06	njohnson@yahoo.com
114	Post 9	published	2023-01-13	odavis@gmail.com
115	Post 10	published	2022-03-13	lwilson@hotmail.com
116	Post 11	published	2022-08-23	smoore@yahoo.com
117	Post 12	published	2022-11-02	ebrown@gmail.com
118	Post 13	published	2022-03-18	ilee@hotmail.com
119	Post 14	published	2023-01-14	mgarcia@yahoo.com
120	Post 15	published	2023-01-16	mrodriguez@gmail.com
121	Post 1	published	2022-11-27	johndoe@example.com
122	Post 2	published	2022-05-24	janedoe@example.com
123	Post 3	published	2022-09-25	bobsmith@example.com
124	Post 4	published	2023-01-01	alicejones@example.com
125	Post 5	published	2022-05-17	davidbrown@example.com
126	Post 6	published	2022-11-30	amartin@gmail.com
127	Post 7	draft	2022-10-18	esmith@hotmail.com
128	Post 8	published	2022-08-05	njohnson@yahoo.com
129	Post 9	draft	2022-05-19	odavis@gmail.com
130	Post 10	published	2022-10-31	lwilson@hotmail.com
131	Post 11	published	2022-06-13	smoore@yahoo.com
132	Post 12	published	2022-04-01	ebrown@gmail.com
133	Post 13	published	2022-04-17	ilee@hotmail.com
134	Post 14	published	2022-04-29	mgarcia@yahoo.com
135	Post 15	published	2022-05-12	mrodriguez@gmail.com
136	Post 1	published	2022-07-14	johndoe@example.com
137	Post 2	published	2022-12-27	janedoe@example.com
138	Post 3	published	2022-11-26	bobsmith@example.com
139	Post 4	published	2022-05-26	alicejones@example.com
140	Post 5	published	2022-05-16	davidbrown@example.com
141	Post 6	published	2022-12-24	amartin@gmail.com
142	Post 7	published	2022-05-23	esmith@hotmail.com
143	Post 8	draft	2022-09-27	njohnson@yahoo.com
144	Post 9	published	2022-09-18	odavis@gmail.com
145	Post 10	published	2022-12-23	lwilson@hotmail.com
146	Post 11	published	2022-04-25	smoore@yahoo.com
147	Post 12	published	2023-02-03	ebrown@gmail.com
148	Post 13	draft	2022-04-10	ilee@hotmail.com
149	Post 14	published	2022-09-10	mgarcia@yahoo.com
150	Post 15	published	2022-09-15	mrodriguez@gmail.com
151	Post 1	published	2022-05-14	johndoe@example.com
152	Post 2	published	2023-02-01	janedoe@example.com
153	Post 3	published	2023-01-01	bobsmith@example.com
154	Post 4	published	2022-12-07	alicejones@example.com
155	Post 5	draft	2023-01-15	davidbrown@example.com
156	Post 6	published	2022-04-18	amartin@gmail.com
157	Post 7	published	2023-02-20	esmith@hotmail.com
158	Post 8	published	2022-08-03	njohnson@yahoo.com
159	Post 9	published	2022-05-01	odavis@gmail.com
160	Post 10	draft	2022-07-26	lwilson@hotmail.com
161	Post 11	published	2022-05-18	smoore@yahoo.com
162	Post 12	published	2022-11-19	ebrown@gmail.com
163	Post 13	published	2022-10-17	ilee@hotmail.com
164	Post 14	published	2023-02-16	mgarcia@yahoo.com
165	Post 15	published	2022-08-30	mrodriguez@gmail.com
166	Post 1	draft	2022-05-31	johndoe@example.com
167	Post 2	published	2022-03-31	janedoe@example.com
168	Post 3	published	2022-06-04	bobsmith@example.com
169	Post 4	published	2022-11-07	alicejones@example.com
170	Post 5	published	2022-07-10	davidbrown@example.com
171	Post 6	published	2022-09-18	amartin@gmail.com
172	Post 7	published	2022-10-23	esmith@hotmail.com
173	Post 8	published	2022-09-20	njohnson@yahoo.com
174	Post 9	published	2022-11-01	odavis@gmail.com
175	Post 10	published	2023-01-01	lwilson@hotmail.com
176	Post 11	published	2022-09-26	smoore@yahoo.com
177	Post 12	published	2022-06-10	ebrown@gmail.com
178	Post 13	draft	2022-10-12	ilee@hotmail.com
179	Post 14	published	2022-08-26	mgarcia@yahoo.com
180	Post 15	draft	2022-03-16	mrodriguez@gmail.com
181	Post 1	published	2022-03-25	johndoe@example.com
182	Post 2	draft	2022-04-21	janedoe@example.com
183	Post 3	published	2022-04-23	bobsmith@example.com
184	Post 4	published	2022-03-18	alicejones@example.com
185	Post 5	published	2022-11-07	davidbrown@example.com
186	Post 6	published	2023-02-03	amartin@gmail.com
187	Post 7	published	2022-04-25	esmith@hotmail.com
188	Post 8	published	2022-03-16	njohnson@yahoo.com
189	Post 9	published	2023-01-21	odavis@gmail.com
190	Post 10	published	2022-12-05	lwilson@hotmail.com
191	Post 11	published	2022-10-18	smoore@yahoo.com
192	Post 12	draft	2022-06-19	ebrown@gmail.com
193	Post 13	draft	2022-07-14	ilee@hotmail.com
194	Post 14	published	2022-12-08	mgarcia@yahoo.com
195	Post 15	published	2022-12-19	mrodriguez@gmail.com
196	Post 1	published	2022-07-10	johndoe@example.com
197	Post 2	published	2022-08-25	janedoe@example.com
198	Post 3	published	2022-08-14	bobsmith@example.com
199	Post 4	published	2023-02-14	alicejones@example.com
200	Post 5	published	2022-07-18	davidbrown@example.com
201	Post 6	published	2022-05-06	amartin@gmail.com
202	Post 7	published	2022-09-25	esmith@hotmail.com
203	Post 8	published	2022-09-26	njohnson@yahoo.com
204	Post 9	published	2022-10-30	odavis@gmail.com
205	Post 10	published	2022-08-11	lwilson@hotmail.com
206	Post 11	published	2023-02-09	smoore@yahoo.com
207	Post 12	published	2022-04-13	ebrown@gmail.com
208	Post 13	published	2022-03-30	ilee@hotmail.com
209	Post 14	published	2022-06-08	mgarcia@yahoo.com
210	Post 15	published	2022-07-29	mrodriguez@gmail.com
211	Post 1	published	2022-09-08	johndoe@example.com
212	Post 2	published	2022-08-05	janedoe@example.com
213	Post 3	published	2022-10-05	bobsmith@example.com
214	Post 4	published	2022-03-16	alicejones@example.com
215	Post 5	published	2023-02-15	davidbrown@example.com
216	Post 6	published	2022-07-21	amartin@gmail.com
217	Post 7	draft	2022-10-07	esmith@hotmail.com
218	Post 8	published	2023-01-15	njohnson@yahoo.com
219	Post 9	published	2022-06-08	odavis@gmail.com
220	Post 10	published	2022-11-19	lwilson@hotmail.com
221	Post 11	draft	2022-11-29	smoore@yahoo.com
222	Post 12	published	2022-06-08	ebrown@gmail.com
223	Post 13	published	2022-10-01	ilee@hotmail.com
224	Post 14	published	2022-04-07	mgarcia@yahoo.com
225	Post 15	published	2022-06-05	mrodriguez@gmail.com
226	Post 1	published	2023-02-12	johndoe@example.com
227	Post 2	published	2022-12-12	janedoe@example.com
228	Post 3	published	2023-01-03	bobsmith@example.com
229	Post 4	published	2022-06-07	alicejones@example.com
230	Post 5	published	2022-11-27	davidbrown@example.com
231	Post 6	published	2022-04-06	amartin@gmail.com
232	Post 7	published	2022-07-29	esmith@hotmail.com
233	Post 8	published	2022-08-18	njohnson@yahoo.com
234	Post 9	published	2022-12-08	odavis@gmail.com
235	Post 10	published	2022-10-31	lwilson@hotmail.com
236	Post 11	published	2022-09-06	smoore@yahoo.com
237	Post 12	published	2022-05-09	ebrown@gmail.com
238	Post 13	draft	2023-01-19	ilee@hotmail.com
239	Post 14	published	2023-02-20	mgarcia@yahoo.com
240	Post 15	published	2022-03-20	mrodriguez@gmail.com
241	Post 1	published	2023-01-21	johndoe@example.com
242	Post 2	published	2022-11-05	janedoe@example.com
243	Post 3	draft	2022-03-23	bobsmith@example.com
244	Post 4	published	2022-03-22	alicejones@example.com
245	Post 5	published	2022-07-17	davidbrown@example.com
246	Post 6	published	2022-08-06	amartin@gmail.com
247	Post 7	published	2023-02-02	esmith@hotmail.com
248	Post 8	published	2022-06-08	njohnson@yahoo.com
249	Post 9	draft	2022-12-13	odavis@gmail.com
250	Post 10	published	2023-01-22	lwilson@hotmail.com
251	Post 11	draft	2023-02-07	smoore@yahoo.com
252	Post 12	published	2022-11-02	ebrown@gmail.com
253	Post 13	published	2022-04-02	ilee@hotmail.com
254	Post 14	published	2022-11-15	mgarcia@yahoo.com
255	Post 15	published	2022-03-22	mrodriguez@gmail.com
\.


--
-- Data for Name: post_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_comment (cid, ctext, cdate, email, pid_fk, cidfk) FROM stdin;
23	Great post, thanks for sharing!	2023-02-28	johndoe@example.com	1	\N
24	I have a question about this post.	2023-03-02	johndoe@example.com	1	\N
25	I completely agree with you!	2023-03-04	janedoe@example.com	2	\N
26	This post was really helpful, thanks!	2023-03-05	bobsmith@example.com	2	\N
27	Could you provide some more examples?	2023-03-06	alicejones@example.com	2	\N
28	Here is a helpful link I found on this topic.	2023-03-07	davidbrown@example.com	3	\N
29	I think there is a mistake in this post.	2023-03-03	amartin@gmail.com	3	\N
30	Thanks for the great explanation!	2023-03-04	esmith@hotmail.com	3	\N
31	Could you clarify this point for me?	2023-03-05	njohnson@yahoo.com	4	\N
32	I found a typo in this post.	2023-03-06	njohnson@yahoo.com	4	\N
33	This post is very interesting!	2023-03-07	odavis@gmail.com	4	\N
34	I think this post could use some more detail.	2023-03-01	lwilson@hotmail.com	5	\N
35	Thanks for the helpful tips!	2023-03-03	smoore@yahoo.com	5	\N
36	I have a different perspective on this topic.	2023-03-05	ebrown@gmail.com	5	\N
37	I think you missed an important point in this post.	2023-03-06	ilee@hotmail.com	5	\N
38	This post was very useful, thanks!	2023-03-07	mgarcia@yahoo.com	6	\N
39	I had a similar experience, thanks for sharing!	2023-03-02	mrodriguez@gmail.com	6	\N
40	Could you recommend some more resources on this topic?	2023-03-04	mrodriguez@gmail.com	6	\N
41	I think this post is missing some important context.	2023-03-06	mrodriguez@gmail.com	6	\N
42	Thanks for the informative post!	2023-03-07	ebrown@gmail.com	7	\N
43	I have a question about one of the points you made.	2023-03-03	odavis@gmail.com	7	\N
44	I think this post could benefit from some more examples.	2023-03-05	amartin@gmail.com	7	\N
\.


--
-- Data for Name: react; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.react (reaction, email, pid_fk, reaction_num) FROM stdin;
L	mm.motahari.2001@gmail.com	3	1
L	pedram.pooya.2001@gmail.com	3	1
D	janedoe@example.com	2	0
L	bobsmith@example.com	3	1
D	alicejones@example.com	4	0
L	davidbrown@example.com	5	1
D	amartin@gmail.com	6	0
L	esmith@hotmail.com	7	1
D	njohnson@yahoo.com	8	0
L	odavis@gmail.com	9	1
D	lwilson@hotmail.com	10	0
L	smoore@yahoo.com	11	1
D	ebrown@gmail.com	12	0
L	ilee@hotmail.com	13	1
D	mgarcia@yahoo.com	14	0
L	mrodriguez@gmail.com	15	1
D	johndoe@example.com	1	0
D	johndoe@example.com	2	0
D	johndoe@example.com	3	0
D	johndoe@example.com	4	0
D	johndoe@example.com	5	0
D	johndoe@example.com	6	0
D	johndoe@example.com	7	0
D	johndoe@example.com	8	0
D	johndoe@example.com	9	0
D	johndoe@example.com	10	0
D	johndoe@example.com	11	0
D	johndoe@example.com	12	0
D	johndoe@example.com	13	0
D	johndoe@example.com	14	0
D	johndoe@example.com	15	0
D	johndoe@example.com	16	0
D	johndoe@example.com	17	0
D	johndoe@example.com	18	0
D	johndoe@example.com	19	0
D	johndoe@example.com	20	0
D	johndoe@example.com	21	0
D	johndoe@example.com	22	0
D	johndoe@example.com	23	0
D	johndoe@example.com	24	0
D	johndoe@example.com	25	0
D	johndoe@example.com	26	0
D	johndoe@example.com	27	0
D	johndoe@example.com	28	0
D	johndoe@example.com	29	0
D	johndoe@example.com	30	0
D	johndoe@example.com	31	0
D	johndoe@example.com	32	0
D	johndoe@example.com	33	0
D	johndoe@example.com	34	0
D	johndoe@example.com	35	0
D	johndoe@example.com	36	0
D	johndoe@example.com	37	0
D	johndoe@example.com	38	0
D	johndoe@example.com	39	0
D	johndoe@example.com	40	0
D	johndoe@example.com	41	0
D	johndoe@example.com	42	0
D	johndoe@example.com	43	0
D	johndoe@example.com	44	0
D	johndoe@example.com	45	0
D	johndoe@example.com	46	0
D	johndoe@example.com	47	0
D	johndoe@example.com	48	0
D	johndoe@example.com	49	0
D	johndoe@example.com	50	0
D	johndoe@example.com	51	0
D	johndoe@example.com	52	0
D	johndoe@example.com	53	0
D	johndoe@example.com	54	0
D	johndoe@example.com	55	0
D	johndoe@example.com	56	0
D	johndoe@example.com	57	0
D	johndoe@example.com	58	0
D	johndoe@example.com	59	0
D	johndoe@example.com	60	0
D	johndoe@example.com	61	0
D	johndoe@example.com	62	0
D	johndoe@example.com	63	0
D	johndoe@example.com	64	0
D	johndoe@example.com	65	0
D	johndoe@example.com	66	0
D	johndoe@example.com	67	0
D	johndoe@example.com	68	0
D	johndoe@example.com	69	0
D	johndoe@example.com	70	0
D	johndoe@example.com	71	0
D	johndoe@example.com	72	0
D	johndoe@example.com	73	0
D	johndoe@example.com	74	0
D	johndoe@example.com	75	0
D	johndoe@example.com	76	0
D	johndoe@example.com	77	0
D	johndoe@example.com	78	0
D	johndoe@example.com	79	0
D	johndoe@example.com	80	0
D	johndoe@example.com	81	0
D	johndoe@example.com	82	0
D	johndoe@example.com	83	0
D	johndoe@example.com	84	0
D	johndoe@example.com	85	0
D	johndoe@example.com	86	0
D	johndoe@example.com	87	0
D	johndoe@example.com	88	0
D	johndoe@example.com	89	0
D	johndoe@example.com	90	0
D	johndoe@example.com	91	0
D	johndoe@example.com	92	0
D	johndoe@example.com	93	0
D	johndoe@example.com	94	0
D	johndoe@example.com	95	0
D	johndoe@example.com	96	0
\.


--
-- Data for Name: save_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.save_post (email, pid_fk) FROM stdin;
alicejones@example.com	17
njohnson@yahoo.com	8
odavis@gmail.com	6
davidbrown@example.com	3
johndoe@example.com	19
johndoe@example.com	13
ilee@hotmail.com	7
esmith@hotmail.com	8
lwilson@hotmail.com	10
esmith@hotmail.com	12
amartin@gmail.com	30
odavis@gmail.com	20
janedoe@example.com	8
amartin@gmail.com	11
alicejones@example.com	8
davidbrown@example.com	16
mrodriguez@gmail.com	23
esmith@hotmail.com	4
smoore@yahoo.com	4
ebrown@gmail.com	5
alicejones@example.com	2
johndoe@example.com	5
esmith@hotmail.com	9
alicejones@example.com	28
njohnson@yahoo.com	9
davidbrown@example.com	18
mrodriguez@gmail.com	12
mrodriguez@gmail.com	21
johndoe@example.com	18
smoore@yahoo.com	2
janedoe@example.com	3
bobsmith@example.com	11
esmith@hotmail.com	22
johndoe@example.com	11
amartin@gmail.com	22
amartin@gmail.com	21
alicejones@example.com	12
mrodriguez@gmail.com	24
bobsmith@example.com	7
johndoe@example.com	12
davidbrown@example.com	2
ebrown@gmail.com	30
johndoe@example.com	24
odavis@gmail.com	12
ebrown@gmail.com	13
amartin@gmail.com	19
amartin@gmail.com	20
johndoe@example.com	4
janedoe@example.com	29
smoore@yahoo.com	9
smoore@yahoo.com	3
ebrown@gmail.com	20
amartin@gmail.com	29
janedoe@example.com	21
mgarcia@yahoo.com	7
ebrown@gmail.com	17
lwilson@hotmail.com	14
smoore@yahoo.com	7
bobsmith@example.com	22
smoore@yahoo.com	22
mrodriguez@gmail.com	1
ebrown@gmail.com	25
mrodriguez@gmail.com	2
ebrown@gmail.com	10
davidbrown@example.com	22
smoore@yahoo.com	8
lwilson@hotmail.com	26
esmith@hotmail.com	19
johndoe@example.com	28
esmith@hotmail.com	28
janedoe@example.com	16
esmith@hotmail.com	13
mgarcia@yahoo.com	18
alicejones@example.com	7
lwilson@hotmail.com	19
njohnson@yahoo.com	28
mgarcia@yahoo.com	21
amartin@gmail.com	28
ilee@hotmail.com	11
lwilson@hotmail.com	11
janedoe@example.com	26
njohnson@yahoo.com	27
ebrown@gmail.com	6
odavis@gmail.com	18
mgarcia@yahoo.com	29
bobsmith@example.com	27
janedoe@example.com	2
alicejones@example.com	22
lwilson@hotmail.com	27
esmith@hotmail.com	7
johndoe@example.com	7
janedoe@example.com	1
janedoe@example.com	19
amartin@gmail.com	8
smoore@yahoo.com	16
amartin@gmail.com	10
lwilson@hotmail.com	6
mgarcia@yahoo.com	4
amartin@gmail.com	7
esmith@hotmail.com	20
bobsmith@example.com	18
alicejones@example.com	24
mgarcia@yahoo.com	15
mgarcia@yahoo.com	20
mrodriguez@gmail.com	3
johndoe@example.com	17
janedoe@example.com	4
johndoe@example.com	16
ebrown@gmail.com	18
mrodriguez@gmail.com	14
esmith@hotmail.com	16
janedoe@example.com	12
davidbrown@example.com	20
ilee@hotmail.com	29
mgarcia@yahoo.com	27
ebrown@gmail.com	8
alicejones@example.com	29
lwilson@hotmail.com	20
johndoe@example.com	22
ilee@hotmail.com	5
lwilson@hotmail.com	3
bobsmith@example.com	3
smoore@yahoo.com	21
mrodriguez@gmail.com	5
odavis@gmail.com	22
johndoe@example.com	23
ilee@hotmail.com	13
mgarcia@yahoo.com	3
mrodriguez@gmail.com	6
njohnson@yahoo.com	26
ilee@hotmail.com	20
bobsmith@example.com	10
ilee@hotmail.com	15
ilee@hotmail.com	2
smoore@yahoo.com	13
lwilson@hotmail.com	21
esmith@hotmail.com	5
odavis@gmail.com	14
alicejones@example.com	20
amartin@gmail.com	18
ebrown@gmail.com	1
ebrown@gmail.com	14
njohnson@yahoo.com	29
ilee@hotmail.com	14
johndoe@example.com	21
lwilson@hotmail.com	5
johndoe@example.com	25
bobsmith@example.com	20
lwilson@hotmail.com	1
janedoe@example.com	7
odavis@gmail.com	24
amartin@gmail.com	3
smoore@yahoo.com	10
davidbrown@example.com	30
smoore@yahoo.com	28
johndoe@example.com	26
smoore@yahoo.com	25
johndoe@example.com	30
amartin@gmail.com	14
mrodriguez@gmail.com	26
ebrown@gmail.com	7
smoore@yahoo.com	11
janedoe@example.com	13
mrodriguez@gmail.com	25
ebrown@gmail.com	16
amartin@gmail.com	17
mgarcia@yahoo.com	9
odavis@gmail.com	1
alicejones@example.com	6
mrodriguez@gmail.com	16
alicejones@example.com	26
davidbrown@example.com	6
janedoe@example.com	6
lwilson@hotmail.com	23
smoore@yahoo.com	14
ilee@hotmail.com	23
esmith@hotmail.com	26
ebrown@gmail.com	3
davidbrown@example.com	5
odavis@gmail.com	28
davidbrown@example.com	1
smoore@yahoo.com	12
lwilson@hotmail.com	25
johndoe@example.com	10
mgarcia@yahoo.com	25
lwilson@hotmail.com	29
njohnson@yahoo.com	21
bobsmith@example.com	17
davidbrown@example.com	21
ilee@hotmail.com	30
lwilson@hotmail.com	22
ebrown@gmail.com	19
njohnson@yahoo.com	13
smoore@yahoo.com	27
lwilson@hotmail.com	9
smoore@yahoo.com	29
davidbrown@example.com	9
lwilson@hotmail.com	8
davidbrown@example.com	17
mgarcia@yahoo.com	19
mgarcia@yahoo.com	14
janedoe@example.com	10
ebrown@gmail.com	4
mgarcia@yahoo.com	13
esmith@hotmail.com	27
alicejones@example.com	3
odavis@gmail.com	3
mgarcia@yahoo.com	12
ilee@hotmail.com	22
janedoe@example.com	25
bobsmith@example.com	30
ilee@hotmail.com	19
ebrown@gmail.com	24
ilee@hotmail.com	12
janedoe@example.com	23
esmith@hotmail.com	18
davidbrown@example.com	10
lwilson@hotmail.com	15
odavis@gmail.com	19
mrodriguez@gmail.com	22
njohnson@yahoo.com	5
njohnson@yahoo.com	11
davidbrown@example.com	15
davidbrown@example.com	23
janedoe@example.com	17
lwilson@hotmail.com	17
ilee@hotmail.com	3
odavis@gmail.com	21
mgarcia@yahoo.com	16
ilee@hotmail.com	6
davidbrown@example.com	11
smoore@yahoo.com	5
smoore@yahoo.com	23
amartin@gmail.com	13
alicejones@example.com	1
bobsmith@example.com	26
amartin@gmail.com	4
smoore@yahoo.com	30
ilee@hotmail.com	18
davidbrown@example.com	26
bobsmith@example.com	24
ilee@hotmail.com	24
davidbrown@example.com	4
bobsmith@example.com	6
amartin@gmail.com	15
odavis@gmail.com	29
janedoe@example.com	30
ilee@hotmail.com	9
ilee@hotmail.com	27
lwilson@hotmail.com	16
amartin@gmail.com	2
odavis@gmail.com	30
smoore@yahoo.com	18
odavis@gmail.com	13
johndoe@example.com	14
mgarcia@yahoo.com	17
amartin@gmail.com	26
davidbrown@example.com	25
smoore@yahoo.com	19
smoore@yahoo.com	6
esmith@hotmail.com	14
johndoe@example.com	15
smoore@yahoo.com	26
alicejones@example.com	27
ebrown@gmail.com	2
odavis@gmail.com	26
amartin@gmail.com	9
njohnson@yahoo.com	7
ilee@hotmail.com	10
janedoe@example.com	15
esmith@hotmail.com	6
mgarcia@yahoo.com	26
janedoe@example.com	20
alicejones@example.com	14
lwilson@hotmail.com	4
mrodriguez@gmail.com	7
alicejones@example.com	25
mgarcia@yahoo.com	8
davidbrown@example.com	24
mrodriguez@gmail.com	8
odavis@gmail.com	23
bobsmith@example.com	13
mgarcia@yahoo.com	22
mgarcia@yahoo.com	6
bobsmith@example.com	12
odavis@gmail.com	16
bobsmith@example.com	28
esmith@hotmail.com	23
odavis@gmail.com	27
mrodriguez@gmail.com	17
bobsmith@example.com	21
bobsmith@example.com	25
ebrown@gmail.com	15
johndoe@example.com	8
njohnson@yahoo.com	16
ebrown@gmail.com	26
amartin@gmail.com	12
johndoe@example.com	3
njohnson@yahoo.com	17
odavis@gmail.com	2
mgarcia@yahoo.com	5
amartin@gmail.com	5
mrodriguez@gmail.com	30
odavis@gmail.com	7
alicejones@example.com	23
lwilson@hotmail.com	13
alicejones@example.com	19
mgarcia@yahoo.com	1
davidbrown@example.com	29
bobsmith@example.com	23
mgarcia@yahoo.com	23
bobsmith@example.com	19
amartin@gmail.com	24
bobsmith@example.com	5
ebrown@gmail.com	9
njohnson@yahoo.com	4
esmith@hotmail.com	2
bobsmith@example.com	9
odavis@gmail.com	5
mrodriguez@gmail.com	13
esmith@hotmail.com	11
lwilson@hotmail.com	18
bobsmith@example.com	4
johndoe@example.com	9
alicejones@example.com	4
esmith@hotmail.com	15
njohnson@yahoo.com	30
njohnson@yahoo.com	24
odavis@gmail.com	10
janedoe@example.com	24
johndoe@example.com	2
alicejones@example.com	10
odavis@gmail.com	15
alicejones@example.com	13
johndoe@example.com	1
janedoe@example.com	28
esmith@hotmail.com	21
mrodriguez@gmail.com	4
janedoe@example.com	5
lwilson@hotmail.com	28
davidbrown@example.com	8
smoore@yahoo.com	17
johndoe@example.com	27
alicejones@example.com	21
ilee@hotmail.com	21
ebrown@gmail.com	11
odavis@gmail.com	4
bobsmith@example.com	1
alicejones@example.com	5
janedoe@example.com	14
bobsmith@example.com	2
alicejones@example.com	18
davidbrown@example.com	13
ebrown@gmail.com	28
esmith@hotmail.com	17
mgarcia@yahoo.com	10
smoore@yahoo.com	24
amartin@gmail.com	23
alicejones@example.com	30
ebrown@gmail.com	12
mrodriguez@gmail.com	9
mrodriguez@gmail.com	10
odavis@gmail.com	8
njohnson@yahoo.com	23
njohnson@yahoo.com	10
njohnson@yahoo.com	2
davidbrown@example.com	14
mrodriguez@gmail.com	15
ebrown@gmail.com	27
lwilson@hotmail.com	7
mgarcia@yahoo.com	2
alicejones@example.com	15
davidbrown@example.com	7
njohnson@yahoo.com	22
smoore@yahoo.com	15
mrodriguez@gmail.com	20
esmith@hotmail.com	25
odavis@gmail.com	11
lwilson@hotmail.com	2
janedoe@example.com	27
mrodriguez@gmail.com	29
ilee@hotmail.com	26
alicejones@example.com	9
alicejones@example.com	11
esmith@hotmail.com	10
lwilson@hotmail.com	30
bobsmith@example.com	29
amartin@gmail.com	1
bobsmith@example.com	8
amartin@gmail.com	6
davidbrown@example.com	12
johndoe@example.com	29
mrodriguez@gmail.com	19
ilee@hotmail.com	8
davidbrown@example.com	28
smoore@yahoo.com	20
odavis@gmail.com	9
bobsmith@example.com	16
njohnson@yahoo.com	3
esmith@hotmail.com	3
ilee@hotmail.com	25
njohnson@yahoo.com	25
davidbrown@example.com	27
janedoe@example.com	22
bobsmith@example.com	14
ebrown@gmail.com	29
amartin@gmail.com	27
odavis@gmail.com	17
njohnson@yahoo.com	12
ebrown@gmail.com	23
njohnson@yahoo.com	6
janedoe@example.com	18
smoore@yahoo.com	1
mgarcia@yahoo.com	24
esmith@hotmail.com	1
njohnson@yahoo.com	1
mgarcia@yahoo.com	30
amartin@gmail.com	16
mrodriguez@gmail.com	18
njohnson@yahoo.com	15
mrodriguez@gmail.com	28
njohnson@yahoo.com	18
johndoe@example.com	6
njohnson@yahoo.com	20
ebrown@gmail.com	21
esmith@hotmail.com	24
odavis@gmail.com	25
bobsmith@example.com	15
amartin@gmail.com	25
njohnson@yahoo.com	14
johndoe@example.com	20
mgarcia@yahoo.com	11
ilee@hotmail.com	16
davidbrown@example.com	19
janedoe@example.com	9
lwilson@hotmail.com	12
ilee@hotmail.com	1
janedoe@example.com	11
esmith@hotmail.com	30
mgarcia@yahoo.com	28
ilee@hotmail.com	4
lwilson@hotmail.com	24
mrodriguez@gmail.com	27
mrodriguez@gmail.com	11
ilee@hotmail.com	28
esmith@hotmail.com	29
ebrown@gmail.com	22
alicejones@example.com	16
ilee@hotmail.com	17
njohnson@yahoo.com	19
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (text_skills, email) FROM stdin;
Python	amartin@gmail.com
JavaScript	amartin@gmail.com
SQL	amartin@gmail.com
React	amartin@gmail.com
Python	esmith@hotmail.com
Java	esmith@hotmail.com
C++	njohnson@yahoo.com
JavaScript	njohnson@yahoo.com
React	njohnson@yahoo.com
Python	lwilson@hotmail.com
C#	lwilson@hotmail.com
SQL	lwilson@hotmail.com
Python	smoore@yahoo.com
JavaScript	smoore@yahoo.com
Ruby	ebrown@gmail.com
Python	ebrown@gmail.com
SQL	ebrown@gmail.com
Java	ilee@hotmail.com
JavaScript	ilee@hotmail.com
Python	mgarcia@yahoo.com
C++	mgarcia@yahoo.com
JavaScript	mrodriguez@gmail.com
React	mrodriguez@gmail.com
SQL	mrodriguez@gmail.com
objective-c	pedram.pooya.2001@gmail.com
objective-c	pedram.pooya.2002@gmail.com
network+	pedram.pooya.2001@gmail.com
network+	pedram.pooya.2002@gmail.com
objective-c	mgarcia@yahoo.com
objective-c	mrodriguez@gmail.com
network+	mgarcia@yahoo.com
network+	mrodriguez@gmail.com
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (tag, jid_fk) FROM stdin;
Accountant	8
Finance	8
Designer	9
Front-End	9
Artist	9
CSS	9
Bootstrap	9
Sales	10
Front-End	11
CSS	11
SASS	11
UI	11
UX	11
Back-End	12
Python	12
Django	12
Web-Server	12
Driver	13
\.


--
-- Data for Name: user_field; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_field (fname, lname, bdate, sex, email, pic_profile) FROM stdin;
John	Doe	1990-05-15	M	johndoe@example.com	https://picsum.photos/200
Jane	Doe	1995-07-22	F	janedoe@example.com	https://picsum.photos/200
Bob	Smith	1985-01-10	M	bobsmith@example.com	https://picsum.photos/200
Alice	Jones	1988-12-03	F	alicejones@example.com	https://picsum.photos/200
David	Brown	1992-09-18	M	davidbrown@example.com	https://picsum.photos/200
Avery	Martin	1998-01-23	M	amartin@gmail.com	https://picsum.photos/200
Emma	Smith	1995-07-12	F	esmith@hotmail.com	https://picsum.photos/200
Noah	Johnson	2000-04-05	M	njohnson@yahoo.com	https://picsum.photos/200
Olivia	Davis	1993-11-29	F	odavis@gmail.com	https://picsum.photos/200
Liam	Wilson	1996-08-16	M	lwilson@hotmail.com	https://picsum.photos/200
Sophia	Moore	1999-05-19	F	smoore@yahoo.com	https://picsum.photos/200
Ethan	Brown	1997-02-22	M	ebrown@gmail.com	https://picsum.photos/200
Isabella	Lee	1994-09-09	F	ilee@hotmail.com	https://picsum.photos/200
Mason	Garcia	1991-06-30	M	mgarcia@yahoo.com	https://picsum.photos/200
Mia	Rodriguez	1990-12-18	F	mrodriguez@gmail.com	https://picsum.photos/200
Pedram	Pooya	2010-09-11	M	pedram.pooya.2010@gmail.com	https://picsum.photos/200
Pedram	Pooya	2009-09-11	M	pedram.pooya.2009@gmail.com	https://picsum.photos/200
Pedram	Pooya	2008-09-11	M	pedram.pooya.2008@gmail.com	https://picsum.photos/200
Pedram	Pooya	2007-09-11	M	pedram.pooya.2007@gmail.com	https://picsum.photos/200
Pedram	Pooya	2006-09-11	M	pedram.pooya.2006@gmail.com	https://picsum.photos/200
Pedram	Pooya	2005-09-11	M	pedram.pooya.2005@gmail.com	https://picsum.photos/200
Pedram	Pooya	2004-09-11	M	pedram.pooya.2004@gmail.com	https://picsum.photos/200
Pedram	Pooya	2003-09-11	M	pedram.pooya.2003@gmail.com	https://picsum.photos/200
Pedram	Pooya	2002-09-11	M	pedram.pooya.2002@gmail.com	https://picsum.photos/200
Pedram	Pooya	2001-09-11	M	pedram.pooya.2001@gmail.com	https://picsum.photos/200
Muh	Mah	2001-09-27	M	mm.motahari.2001@gmail.com	\N
Erfan	Hamidi	2001-11-27	M	erfan.hamidi@gmail.com	\N
Erfan	Bamdadi	2001-11-27	M	erfan.bamdadi@gmail.com	\N
\.


--
-- Name: job_ad_jid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_jid_seq', 15, true);


--
-- Name: post_comment_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.post_comment_cid_seq', 44, true);


--
-- Name: post_pid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.post_pid_seq', 255, true);


--
-- Name: applicant aemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_pkey PRIMARY KEY (email);


--
-- Name: company crn_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_pkey PRIMARY KEY (crn, email);


--
-- Name: company crn_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_unique UNIQUE (crn);


--
-- Name: employer eemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT eemail_pkey PRIMARY KEY (email);


--
-- Name: experience exppkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT exppkey PRIMARY KEY (email, title, details, company, salary, startdate, enddate);


--
-- Name: images image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT image_pkey PRIMARY KEY (url_image, pid_fk);


--
-- Name: job_ad jid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jid_pkey PRIMARY KEY (jid);


--
-- Name: job_req jpkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jpkey PRIMARY KEY (email, jid);


--
-- Name: post pid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pid_pkey PRIMARY KEY (pid);


--
-- Name: post_comment pstcmnt_prmkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pstcmnt_prmkey PRIMARY KEY (cid);


--
-- Name: react react_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT react_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: save_post save_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT save_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (text_skills, email);


--
-- Name: tags tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_pkey PRIMARY KEY (tag, jid_fk);


--
-- Name: user_field user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_field
    ADD CONSTRAINT user_pkey PRIMARY KEY (email);


--
-- Name: react check_user_reacts; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_user_reacts AFTER INSERT ON public.react FOR EACH ROW EXECUTE FUNCTION public.remove_user_if_dislikes();


--
-- Name: job_ad remove_old_job_ad_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER remove_old_job_ad_trigger AFTER INSERT ON public.job_ad FOR EACH ROW EXECUTE FUNCTION public.remove_old_job_ad();


--
-- Name: applicant aemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: company company_mail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT company_mail_fk FOREIGN KEY (email) REFERENCES public.user_field(email) ON DELETE CASCADE;


--
-- Name: employer crn_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT crn_fk FOREIGN KEY (crn) REFERENCES public.company(crn);


--
-- Name: react email_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT email_fk_react FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: skills email_fk_skills; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT email_fk_skills FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: employer email_fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT email_fk_user FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: save_post email_save; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT email_save FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: experience expemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT expemail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: job_ad jemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jemail_fk FOREIGN KEY (email) REFERENCES public.employer(email);


--
-- Name: job_req jid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jid_fk FOREIGN KEY (jid) REFERENCES public.job_ad(jid) ON DELETE CASCADE;


--
-- Name: tags jid_tag; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT jid_tag FOREIGN KEY (jid_fk) REFERENCES public.job_ad(jid) ON DELETE CASCADE;


--
-- Name: job_req jremail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jremail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: post_comment pcemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pcemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: post pemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: react pid_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT pid_fk_react FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: save_post pid_save; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT pid_save FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: images post_image; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT post_image FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment postcommentpid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT postcommentpid_fk FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment reply_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT reply_fk FOREIGN KEY (cidfk) REFERENCES public.post_comment(cid);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- Database "woodendoor" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Homebrew)
-- Dumped by pg_dump version 14.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: woodendoor; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE woodendoor WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C';


ALTER DATABASE woodendoor OWNER TO postgres;

\connect woodendoor

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applicant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applicant (
    email character varying(255) NOT NULL,
    country character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    app_address character varying(100),
    req_salary bigint
);


ALTER TABLE public.applicant OWNER TO postgres;

--
-- Name: company; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company (
    cname character varying(50) NOT NULL,
    noe integer NOT NULL,
    crn character varying(20) NOT NULL,
    email character varying(255) NOT NULL,
    country character varying(20),
    city character varying(20),
    com_address character varying(50)
);


ALTER TABLE public.company OWNER TO postgres;

--
-- Name: employer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employer (
    email character varying(255) NOT NULL,
    crn character varying(20) NOT NULL,
    "position" character varying(20)
);


ALTER TABLE public.employer OWNER TO postgres;

--
-- Name: experience; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experience (
    email character varying(255) NOT NULL,
    title character varying(50) NOT NULL,
    details character varying(255) NOT NULL,
    company character varying(20) NOT NULL,
    salary bigint NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE public.experience OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    url_image character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: job_ad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_ad (
    jid integer NOT NULL,
    jdate date NOT NULL,
    title character varying(50) NOT NULL,
    visibility boolean NOT NULL,
    jstate character varying(10),
    email character varying(255) NOT NULL,
    country character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    app_address character varying(100) NOT NULL,
    job_description text
);


ALTER TABLE public.job_ad OWNER TO postgres;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_ad_jid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_jid_seq OWNER TO postgres;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_ad_jid_seq OWNED BY public.job_ad.jid;


--
-- Name: job_req; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_req (
    jid integer NOT NULL,
    email character varying(255) NOT NULL,
    reqstate character varying(10) NOT NULL,
    reqdate date NOT NULL,
    reqtext character varying(255),
    reqresume text
);


ALTER TABLE public.job_req OWNER TO postgres;

--
-- Name: job_req_jid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_req_jid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_req_jid_seq OWNER TO postgres;

--
-- Name: job_req_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_req_jid_seq OWNED BY public.job_req.jid;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post (
    pid integer NOT NULL,
    ptext text,
    pstate character varying(10) NOT NULL,
    pdate date NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.post OWNER TO postgres;

--
-- Name: post_comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_comment (
    cid integer NOT NULL,
    ctext character varying(255) NOT NULL,
    cdate date NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL,
    cidfk integer
);


ALTER TABLE public.post_comment OWNER TO postgres;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.post_comment_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_comment_cid_seq OWNER TO postgres;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.post_comment_cid_seq OWNED BY public.post_comment.cid;


--
-- Name: post_pid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.post_pid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_pid_seq OWNER TO postgres;

--
-- Name: post_pid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.post_pid_seq OWNED BY public.post.pid;


--
-- Name: react; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.react (
    reaction character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.react OWNER TO postgres;

--
-- Name: save_post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.save_post (
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.save_post OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    text_skills character varying(100) NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    tag character varying(50) NOT NULL,
    jid_fk integer NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: user_field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_field (
    fname character varying(50) NOT NULL,
    lname character varying(50) NOT NULL,
    bdate date NOT NULL,
    sex character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pic_profile character varying(255)
);


ALTER TABLE public.user_field OWNER TO postgres;

--
-- Name: job_ad jid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad ALTER COLUMN jid SET DEFAULT nextval('public.job_ad_jid_seq'::regclass);


--
-- Name: job_req jid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req ALTER COLUMN jid SET DEFAULT nextval('public.job_req_jid_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: post pid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post ALTER COLUMN pid SET DEFAULT nextval('public.post_pid_seq'::regclass);


--
-- Name: post_comment cid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment ALTER COLUMN cid SET DEFAULT nextval('public.post_comment_cid_seq'::regclass);


--
-- Data for Name: applicant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applicant (email, country, city, app_address, req_salary) FROM stdin;
\.


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company (cname, noe, crn, email, country, city, com_address) FROM stdin;
\.


--
-- Data for Name: employer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employer (email, crn, "position") FROM stdin;
\.


--
-- Data for Name: experience; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.experience (email, title, details, company, salary, startdate, enddate) FROM stdin;
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (url_image, pid_fk) FROM stdin;
\.


--
-- Data for Name: job_ad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_ad (jid, jdate, title, visibility, jstate, email, country, city, app_address, job_description) FROM stdin;
\.


--
-- Data for Name: job_req; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_req (jid, email, reqstate, reqdate, reqtext, reqresume) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	2019_12_14_000001_create_personal_access_tokens_table	1
2	2023_02_24_201145_sql-file	1
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post (pid, ptext, pstate, pdate, email) FROM stdin;
\.


--
-- Data for Name: post_comment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.post_comment (cid, ctext, cdate, email, pid_fk, cidfk) FROM stdin;
\.


--
-- Data for Name: react; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.react (reaction, email, pid_fk) FROM stdin;
\.


--
-- Data for Name: save_post; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.save_post (email, pid_fk) FROM stdin;
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (text_skills, email) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (tag, jid_fk) FROM stdin;
\.


--
-- Data for Name: user_field; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_field (fname, lname, bdate, sex, email, pic_profile) FROM stdin;
\.


--
-- Name: job_ad_jid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_ad_jid_seq', 1, false);


--
-- Name: job_req_jid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_req_jid_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 2, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: post_comment_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.post_comment_cid_seq', 1, false);


--
-- Name: post_pid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.post_pid_seq', 1, false);


--
-- Name: applicant aemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_pkey PRIMARY KEY (email);


--
-- Name: company crn_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_pkey PRIMARY KEY (crn, email);


--
-- Name: company crn_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_unique UNIQUE (crn);


--
-- Name: employer eemail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT eemail_pkey PRIMARY KEY (email);


--
-- Name: experience exppkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT exppkey PRIMARY KEY (email, title, details, company, salary, startdate, enddate);


--
-- Name: images image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT image_pkey PRIMARY KEY (url_image, pid_fk);


--
-- Name: job_ad jid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jid_pkey PRIMARY KEY (jid);


--
-- Name: job_req jpkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jpkey PRIMARY KEY (email, jid);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: post pid_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pid_pkey PRIMARY KEY (pid);


--
-- Name: post_comment pstcmnt_prmkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pstcmnt_prmkey PRIMARY KEY (cid);


--
-- Name: react react_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT react_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: save_post save_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT save_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (text_skills, email);


--
-- Name: tags tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_pkey PRIMARY KEY (tag, jid_fk);


--
-- Name: user_field user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_field
    ADD CONSTRAINT user_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: applicant aemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: employer crn_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT crn_fk FOREIGN KEY (crn) REFERENCES public.company(crn);


--
-- Name: react email_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT email_fk_react FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: skills email_fk_skills; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT email_fk_skills FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: employer email_fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT email_fk_user FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: save_post email_save; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT email_save FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: experience expemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT expemail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: job_ad jemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jemail_fk FOREIGN KEY (email) REFERENCES public.employer(email);


--
-- Name: job_req jid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jid_fk FOREIGN KEY (jid) REFERENCES public.job_ad(jid);


--
-- Name: tags jid_tag; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT jid_tag FOREIGN KEY (jid_fk) REFERENCES public.job_ad(jid);


--
-- Name: job_req jremail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jremail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: company mail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT mail_fk FOREIGN KEY (email) REFERENCES public.employer(email);


--
-- Name: post_comment pcemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pcemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: post pemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: react pid_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT pid_fk_react FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: save_post pid_save; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT pid_save FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: images post_image; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT post_image FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment postcommentpid_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT postcommentpid_fk FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment reply_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT reply_fk FOREIGN KEY (cidfk) REFERENCES public.post_comment(cid);


--
-- Name: DATABASE woodendoor; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE woodendoor TO postgres;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

