use woodendoor;

CREATE table User_field(

	fname varchar(50) not null,
	lname varchar(50) not null,
	bdate    date NOT null,
	sex      char NOT null,
	email   varchar(255) not null,
	pic_profile varchar(255) ,
	CONSTRAINT user_pkey PRIMARY KEY (email)

);


CREATE table Company(
  cname varchar(50) not null,
  noe int not null,
  crn varchar(20) not null ,
  email varchar(255) not null,
  country varchar(20),
  city varchar(20),
  com_address varchar(50),
  CONSTRAINT  crn_pkey PRIMARY KEY (crn,email),
				CONSTRAINT  crn_unique unique (crn)
				#//CONSTRAINT email_pkey PRIMARY KEY (email),
				#//CONSTRAINT email_fk foreign key (email) references Employer(email)  


);


CREATE table Employer(

  email varchar(255) not null, 
  crn varchar(20) not null,
	Position varchar(20),
  CONSTRAINT eemail_pkey PRIMARY KEY (email),
  CONSTRAINT email_fk_user foreign key (email) references User_field(email),
  CONSTRAINT crn_fk foreign key (crn) references Company(crn) 

);


alter table Company add CONSTRAINT mail_fk foreign key (email) references Employer(email);


CREATE table Applicant(

  email varchar(255) not null,
  country varchar(20) not null,
  city varchar(20) not null,
  app_address varchar(100),
  req_salary bigint ,
  CONSTRAINT aemail_fk foreign key (email) references User_field(email),
  CONSTRAINT aemail_pkey PRIMARY KEY (email)

);


CREATE table Job_ad(

  JID int not null auto_increment,
  jdate datetime not null,
  title varchar(50) not null,
  visibility boolean not null,
  jstate varchar(10),
  email varchar(255) not null,
  country varchar(20) not null,
  city varchar(20) not null,
  app_address varchar(100) not null,
  job_description varchar(255),
  CONSTRAINT JID_pkey PRIMARY KEY (JID),
  CONSTRAINT jemail_fk foreign key (email) references Employer(email)

);


CREATE table Post(

	PID int not null auto_increment,
	ptext varchar(255),
	pstate varchar(10) not null,
	pdate datetime not null,
	email varchar(255) not null,
	CONSTRAINT pID_pkey PRIMARY KEY (pID), 
	CONSTRAINT pemail_fk foreign key (email) references User_field(email)

);


CREATE table Experience(

	email varchar(255) not null,
	title varchar(50) not null,
	details varchar(255),
	Company varchar(20),
	salary bigint not null,
	startdate date not null,
	enddate date not null,
	CONSTRAINT exppkey PRIMARY KEY (email,title,details,Company,salary,startdate,enddate),
	CONSTRAINT expemail_fk foreign key (email) references Applicant(email)

);


CREATE table Job_req(

	jid int not null auto_increment,
	email varchar(255) not null,
	reqstate varchar(10) not null,
	reqdate date not null,
	reqtext varchar(255),
	reqresume text,
	CONSTRAINT jpkey PRIMARY KEY (email,jid),
	CONSTRAINT jremail_fk foreign key (email) references Applicant(email),
	CONSTRAINT jid_fk foreign key (jid) references Job_ad(JID)

);

CREATE TABLE Post_comment (
  CID int not null auto_increment,
  ctext varchar(255) not null,
  cdate date not null,
  email varchar(255) not null,
  PID_FK int not null,
  cidFK int,
  constraint pstcmnt_prmkey PRIMARY KEY (CID),
  CONSTRAINT postcommentpid_fk FOREIGN KEY (PID_FK) REFERENCES Post(PID),
  CONSTRAINT reply_fk foreign key (cidFK) references Post_comment(CID),
  CONSTRAINT pcemail_fk FOREIGN KEY (email) REFERENCES User_field(email)
);


CREATE table Tags(

	tag varchar(50) not null,
	jid_fk int not null,
	CONSTRAINT tag_pkey PRIMARY KEY (tag,jid_fk),
	CONSTRAINT jid_tag foreign key (jid_fk) references Job_ad(JID)

);


CREATE table Images(

  url_image varchar(255) not null,
  pid_fk int not null,
  CONSTRAINT image_pkey PRIMARY KEY(url_image,pid_fk),
  CONSTRAINT Post_image foreign key (pid_fk) references Post(pID)

);


CREATE table Skills(

	text_Skills varchar(100) not null,
	email varchar(255) not null,
	CONSTRAINT Skills_pkey PRIMARY key  (text_Skills,email),
	CONSTRAINT email_fk_Skills foreign key (email) references Applicant(email)

);


CREATE table React(

	Reaction char not null,
	email varchar(255) not null,
	pid_fk int not null,
	CONSTRAINT React_pkey PRIMARY KEY (email,pid_fk),
	CONSTRAINT email_fk_React foreign key (email) references User_field(email),
	CONSTRAINT pid_fk_React foreign key (pid_fk) references Post(pID)

);


CREATE table Save_post(

	email varchar(255) not null,
	pid_fk int not null,
	CONSTRAINT save_pkey PRIMARY key (email, pid_fk),
	CONSTRAINT email_save foreign key (email) references User_field(email),
	CONSTRAINT pid_save foreign key (pid_fk) references Post(pID)

);
