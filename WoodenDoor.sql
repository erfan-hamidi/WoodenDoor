--CREATE DATABASE WoodenDoor;


CREATE table User_feild(

    fname varchar(20) not null,
    lname varchar(20) not null,
    bdate    date NOT null,
    sex      char NOT null,
    email   text not null,
    pic_profile BYTEA ,
    CONSTRAINT user_pkey PRIMARY KEY (email)

);


CREATE table Company(
    cname varchar(20) not null,
    noe int not null,
    crn char(20) not null ,
    email text not null,
    country varchar(20),
    city varchar(20),
    com_address varchar(50),
    CONSTRAINT  crn_pkey PRIMARY KEY (crn,email),
	CONSTRAINT  crn_unique unique (crn)
    --CONSTRAINT email_pkey PRIMARY KEY (email),
    --CONSTRAINT email_fk foreign key (email) references Employer(email)  
);


CREATE table Employer(
    email text not null, 
    crn char(20) not null,
	CONSTRAINT eemail_pkey PRIMARY KEY (email),
    CONSTRAINT email_fk_user foreign key (email) references User_feild(email),
    CONSTRAINT crn_fk foreign key (crn) references Company(crn) 
);

alter table Company add CONSTRAINT mail_fk foreign key (email) references Employer(email);

CREATE table Applicant(
     email text not null,
     country varchar(20),
     city varchar(20),
     app_address varchar(50),
     req_salary bigint ,
     CONSTRAINT email_fk foreign key (email) references User_feild(email),
     CONSTRAINT email_pkey PRIMARY KEY (email)
    
);

CREATE table Job_ad(
    JID serial not null,
    jdate timestamp not null,
    title text,
    visibility boolean not null,
    jstate char,
    email text not null,
    country varchar(20),
    city varchar(20),
    app_address varchar(50),
    job_description text,
    CONSTRAINT JID_pkey PRIMARY KEY (JID),
    CONSTRAINT jemail_fk foreign key (email) references Employer(email)
);

CREATE table post(
    pID serial not null,
    ptext text,
    pstate char not null,
    pdate timestamp not null,
    email text,
    CONSTRAINT email_fk foreign key (email) references User_feild(email),
    CONSTRAINT ID_pkey PRIMARY key (pID) 

);


CREATE table Experience(
    email text not null,
    title text,
    details text,
    company char(20),
    salary bigint,
    startdate date,
    enddate date,
    CONSTRAINT exppkey PRIMARY KEY (email,title,details,company,salary,startdate,enddate),
    CONSTRAINT email_fk foreign key (email) references Applicant(email)
);

CREATE table job_req(
    jid int not null,
    email text not null,
    reqstate char,
    reqdate timestamp,
    reqtext text,
    reqresume text,
    CONSTRAINT pkey PRIMARY KEY (email,jid),
    CONSTRAINT email_fk foreign key (email) references Applicant(email),
    CONSTRAINT jid_fk foreign key (jid) references Job_ad(JID)
);

CREATE table post_comment(
    CID serial not null,
    ctext text,
    cdate timestamp,
    email text not null,
    pid int,
    cidFK int,
    CONSTRAINT email_fk foreign key (email) references User_feild(email),
    CONSTRAINT pid_fk foreign key (pid) references post(pID),
    CONSTRAINT CID_pkey PRIMARY KEY (CID)
    
);

alter table post_comment add CONSTRAINT reply_fk foreign key (cidFK) references post_comment(cidFK);

CREATE table Tags(
    tag varchar(50) not null,
    jid_fk int not null,
    CONSTRAINT tag_pkey PRIMARY KEY (tag,jid_fk),
    CONSTRAINT jid_tag foreign key (jid_fk) references job_ad(JID)

);

CREATE table images(
    url_image text,
    pid_fk int not null,
    CONSTRAINT image_pkey PRIMARY KEY(url_image,pid_fk),
    CONSTRAINT post_image foreign key (pid_fk) references post(pID)

);

CREATE table skill(
    text_skill text,
    email text,
    CONSTRAINT skill_pkey PRIMARY key  (text_skill,email),
    CONSTRAINT email_fk_skill foreign key (email) references Applicant(email)
);

CREATE table react(
    reaction char,
    email text,
    pid_fk int,
    CONSTRAINT react_pkey PRIMARY KEY (email,pid_fk),
    CONSTRAINT email_fk_react foreign key (email) references User_feild(email),
    CONSTRAINT pid_fk_react foreign key (pid_fk) references post(pID)
);

CREATE table save_post(
    email text,
    pid_fk int,
    CONSTRAINT save_pkey PRIMARY key (email, pid_fk),
    CONSTRAINT email_save foreign key (email) references User_feild(email),
    CONSTRAINT pid_save foreign key (pid_fk) references post(pID)
);