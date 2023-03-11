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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applicant; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.applicant (
    email character varying(255) NOT NULL,
    country character varying(20) NOT NULL,
    city character varying(20) NOT NULL,
    app_address character varying(100),
    req_salary bigint
);


ALTER TABLE public.applicant OWNER TO newuser;

--
-- Name: company; Type: TABLE; Schema: public; Owner: newuser
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


ALTER TABLE public.company OWNER TO newuser;

--
-- Name: employer; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.employer (
    email character varying(255) NOT NULL,
    crn character varying(20) NOT NULL,
    "position" character varying(20)
);


ALTER TABLE public.employer OWNER TO newuser;

--
-- Name: experience; Type: TABLE; Schema: public; Owner: newuser
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


ALTER TABLE public.experience OWNER TO newuser;

--
-- Name: images; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.images (
    url_image character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.images OWNER TO newuser;

--
-- Name: job_ad; Type: TABLE; Schema: public; Owner: newuser
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


ALTER TABLE public.job_ad OWNER TO newuser;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.job_ad_jid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_ad_jid_seq OWNER TO newuser;

--
-- Name: job_ad_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.job_ad_jid_seq OWNED BY public.job_ad.jid;


--
-- Name: job_req; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.job_req (
    jid integer NOT NULL,
    email character varying(255) NOT NULL,
    reqstate character varying(10) NOT NULL,
    reqdate date NOT NULL,
    reqtext character varying(255),
    reqresume text
);


ALTER TABLE public.job_req OWNER TO newuser;

--
-- Name: job_req_jid_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.job_req_jid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_req_jid_seq OWNER TO newuser;

--
-- Name: job_req_jid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.job_req_jid_seq OWNED BY public.job_req.jid;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO newuser;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO newuser;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: newuser
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


ALTER TABLE public.personal_access_tokens OWNER TO newuser;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personal_access_tokens_id_seq OWNER TO newuser;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: post; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.post (
    pid integer NOT NULL,
    ptext text,
    pstate character varying(10) NOT NULL,
    pdate date NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.post OWNER TO newuser;

--
-- Name: post_comment; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.post_comment (
    cid integer NOT NULL,
    ctext character varying(255) NOT NULL,
    cdate date NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL,
    cidfk integer
);


ALTER TABLE public.post_comment OWNER TO newuser;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.post_comment_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_comment_cid_seq OWNER TO newuser;

--
-- Name: post_comment_cid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.post_comment_cid_seq OWNED BY public.post_comment.cid;


--
-- Name: post_pid_seq; Type: SEQUENCE; Schema: public; Owner: newuser
--

CREATE SEQUENCE public.post_pid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_pid_seq OWNER TO newuser;

--
-- Name: post_pid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: newuser
--

ALTER SEQUENCE public.post_pid_seq OWNED BY public.post.pid;


--
-- Name: react; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.react (
    reaction character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.react OWNER TO newuser;

--
-- Name: save_post; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.save_post (
    email character varying(255) NOT NULL,
    pid_fk integer NOT NULL
);


ALTER TABLE public.save_post OWNER TO newuser;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.skills (
    text_skills character varying(100) NOT NULL,
    email character varying(255) NOT NULL
);


ALTER TABLE public.skills OWNER TO newuser;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.tags (
    tag character varying(50) NOT NULL,
    jid_fk integer NOT NULL
);


ALTER TABLE public.tags OWNER TO newuser;

--
-- Name: user_field; Type: TABLE; Schema: public; Owner: newuser
--

CREATE TABLE public.user_field (
    fname character varying(50) NOT NULL,
    lname character varying(50) NOT NULL,
    bdate date NOT NULL,
    sex character(1) NOT NULL,
    email character varying(255) NOT NULL,
    pic_profile character varying(255)
);


ALTER TABLE public.user_field OWNER TO newuser;

--
-- Name: job_ad jid; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_ad ALTER COLUMN jid SET DEFAULT nextval('public.job_ad_jid_seq'::regclass);


--
-- Name: job_req jid; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_req ALTER COLUMN jid SET DEFAULT nextval('public.job_req_jid_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: post pid; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post ALTER COLUMN pid SET DEFAULT nextval('public.post_pid_seq'::regclass);


--
-- Name: post_comment cid; Type: DEFAULT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post_comment ALTER COLUMN cid SET DEFAULT nextval('public.post_comment_cid_seq'::regclass);


--
-- Data for Name: applicant; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.applicant (email, country, city, app_address, req_salary) FROM stdin;
\.


--
-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.company (cname, noe, crn, email, country, city, com_address) FROM stdin;
\.


--
-- Data for Name: employer; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.employer (email, crn, "position") FROM stdin;
\.


--
-- Data for Name: experience; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.experience (email, title, details, company, salary, startdate, enddate) FROM stdin;
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.images (url_image, pid_fk) FROM stdin;
\.


--
-- Data for Name: job_ad; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.job_ad (jid, jdate, title, visibility, jstate, email, country, city, app_address, job_description) FROM stdin;
\.


--
-- Data for Name: job_req; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.job_req (jid, email, reqstate, reqdate, reqtext, reqresume) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.migrations (id, migration, batch) FROM stdin;
1	2019_12_14_000001_create_personal_access_tokens_table	1
2	2023_02_24_201145_sql-file	1
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.post (pid, ptext, pstate, pdate, email) FROM stdin;
\.


--
-- Data for Name: post_comment; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.post_comment (cid, ctext, cdate, email, pid_fk, cidfk) FROM stdin;
\.


--
-- Data for Name: react; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.react (reaction, email, pid_fk) FROM stdin;
\.


--
-- Data for Name: save_post; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.save_post (email, pid_fk) FROM stdin;
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.skills (text_skills, email) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.tags (tag, jid_fk) FROM stdin;
\.


--
-- Data for Name: user_field; Type: TABLE DATA; Schema: public; Owner: newuser
--

COPY public.user_field (fname, lname, bdate, sex, email, pic_profile) FROM stdin;
\.


--
-- Name: job_ad_jid_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.job_ad_jid_seq', 1, false);


--
-- Name: job_req_jid_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.job_req_jid_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.migrations_id_seq', 2, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: post_comment_cid_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.post_comment_cid_seq', 1, false);


--
-- Name: post_pid_seq; Type: SEQUENCE SET; Schema: public; Owner: newuser
--

SELECT pg_catalog.setval('public.post_pid_seq', 1, false);


--
-- Name: applicant aemail_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_pkey PRIMARY KEY (email);


--
-- Name: company crn_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_pkey PRIMARY KEY (crn, email);


--
-- Name: company crn_unique; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT crn_unique UNIQUE (crn);


--
-- Name: employer eemail_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT eemail_pkey PRIMARY KEY (email);


--
-- Name: experience exppkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT exppkey PRIMARY KEY (email, title, details, company, salary, startdate, enddate);


--
-- Name: images image_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT image_pkey PRIMARY KEY (url_image, pid_fk);


--
-- Name: job_ad jid_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jid_pkey PRIMARY KEY (jid);


--
-- Name: job_req jpkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jpkey PRIMARY KEY (email, jid);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: post pid_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pid_pkey PRIMARY KEY (pid);


--
-- Name: post_comment pstcmnt_prmkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pstcmnt_prmkey PRIMARY KEY (cid);


--
-- Name: react react_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT react_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: save_post save_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT save_pkey PRIMARY KEY (email, pid_fk);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (text_skills, email);


--
-- Name: tags tag_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tag_pkey PRIMARY KEY (tag, jid_fk);


--
-- Name: user_field user_pkey; Type: CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.user_field
    ADD CONSTRAINT user_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: newuser
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: applicant aemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.applicant
    ADD CONSTRAINT aemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: employer crn_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT crn_fk FOREIGN KEY (crn) REFERENCES public.company(crn);


--
-- Name: react email_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT email_fk_react FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: skills email_fk_skills; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT email_fk_skills FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: employer email_fk_user; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT email_fk_user FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: save_post email_save; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT email_save FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: experience expemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.experience
    ADD CONSTRAINT expemail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: job_ad jemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_ad
    ADD CONSTRAINT jemail_fk FOREIGN KEY (email) REFERENCES public.employer(email);


--
-- Name: job_req jid_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jid_fk FOREIGN KEY (jid) REFERENCES public.job_ad(jid);


--
-- Name: tags jid_tag; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT jid_tag FOREIGN KEY (jid_fk) REFERENCES public.job_ad(jid);


--
-- Name: job_req jremail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.job_req
    ADD CONSTRAINT jremail_fk FOREIGN KEY (email) REFERENCES public.applicant(email);


--
-- Name: company mail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.company
    ADD CONSTRAINT mail_fk FOREIGN KEY (email) REFERENCES public.employer(email);


--
-- Name: post_comment pcemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT pcemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: post pemail_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT pemail_fk FOREIGN KEY (email) REFERENCES public.user_field(email);


--
-- Name: react pid_fk_react; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.react
    ADD CONSTRAINT pid_fk_react FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: save_post pid_save; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.save_post
    ADD CONSTRAINT pid_save FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: images post_image; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT post_image FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment postcommentpid_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT postcommentpid_fk FOREIGN KEY (pid_fk) REFERENCES public.post(pid);


--
-- Name: post_comment reply_fk; Type: FK CONSTRAINT; Schema: public; Owner: newuser
--

ALTER TABLE ONLY public.post_comment
    ADD CONSTRAINT reply_fk FOREIGN KEY (cidfk) REFERENCES public.post_comment(cid);


--
-- PostgreSQL database dump complete
--

