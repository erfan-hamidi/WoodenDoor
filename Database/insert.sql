-- User_field
/*
INSERT INTO User_field (fname, lname, bdate, sex, email, pic_profile)
VALUES
('John', 'Doe', '1990-05-15', 'M', 'johndoe@example.com', 'https://picsum.photos/200'),
('Jane', 'Doe', '1995-07-22', 'F', 'janedoe@example.com', 'https://picsum.photos/200'),
('Bob', 'Smith', '1985-01-10', 'M', 'bobsmith@example.com', 'https://picsum.photos/200'),
('Alice', 'Jones', '1988-12-03', 'F', 'alicejones@example.com', 'https://picsum.photos/200'),
('David', 'Brown', '1992-09-18', 'M', 'davidbrown@example.com', 'https://picsum.photos/200'),
('Avery', 'Martin', '1998-01-23', 'M', 'amartin@gmail.com', 'https://picsum.photos/200'),
('Emma', 'Smith', '1995-07-12', 'F', 'esmith@hotmail.com', 'https://picsum.photos/200'),
('Noah', 'Johnson', '2000-04-05', 'M', 'njohnson@yahoo.com', 'https://picsum.photos/200'),
('Olivia', 'Davis', '1993-11-29', 'F', 'odavis@gmail.com', 'https://picsum.photos/200'),
('Liam', 'Wilson', '1996-08-16', 'M', 'lwilson@hotmail.com', 'https://picsum.photos/200'),
('Sophia', 'Moore', '1999-05-19', 'F', 'smoore@yahoo.com', 'https://picsum.photos/200'),
('Ethan', 'Brown', '1997-02-22', 'M', 'ebrown@gmail.com', 'https://picsum.photos/200'),
('Isabella', 'Lee', '1994-09-09', 'F', 'ilee@hotmail.com', 'https://picsum.photos/200'),
('Mason', 'Garcia', '1991-06-30', 'M', 'mgarcia@yahoo.com', 'https://picsum.photos/200'),
('Mia', 'Rodriguez', '1990-12-18', 'F', 'mrodriguez@gmail.com', 'https://picsum.photos/200');
*/


-- Applicant
/*
INSERT INTO Applicant (email, country, city, app_address, req_salary)
VALUES
('amartin@gmail.com', 'USA', 'New York', '123 Main St', 50000),
('esmith@hotmail.com', 'Canada', 'Toronto', '456 Elm St', 60000),
('njohnson@yahoo.com', 'USA', 'Los Angeles', '789 Oak St', 55000),
('odavis@gmail.com', 'Australia', 'Sydney', NULL, 70000),
('lwilson@hotmail.com', 'USA', 'Chicago', '456 Pine St', 65000),
('smoore@yahoo.com', 'Canada', 'Vancouver', NULL, 55000),
('ebrown@gmail.com', 'USA', 'San Francisco', '789 Maple St', 75000),
('ilee@hotmail.com', 'Australia', 'Melbourne', '123 Cherry St', 60000),
('mgarcia@yahoo.com', 'USA', 'Houston', '456 Cedar St', 55000),
('mrodriguez@gmail.com', 'Canada', 'Montreal', NULL, 70000);
*/


-- Employer
/*
INSERT INTO Employer (email, crn, Position) VALUES
    ('johndoe@example.com', 'CRN123', 'CEO'),
    ('janedoe@example.com', 'CRN456', 'CTO'),
    ('bobsmith@example.com', 'CRN789', 'CFO'),
    ('alicejones@example.com', 'CRN987', 'COO'),
    ('davidbrown@example.com', 'CRN654', 'VP of Marketing');
*/


--Company
/*
INSERT INTO Company (cname, noe, crn, email, country, city, com_address) VALUES
    ('Acme Corp', 500, 'CRN123', 'johndoe@example.com', 'USA', 'New York', '123 Main St'),
    ('Globex Inc', 1000, 'CRN456', 'janedoe@example.com', 'USA', 'Los Angeles', '456 Oak Ave'),
    ('Initech LLC', 250, 'CRN789', 'bobsmith@example.com', 'USA', 'Chicago', '789 Elm St'),
    ('Wayne Enterprises', 750, 'CRN987', 'alicejones@example.com', 'USA', 'Gotham City', '987 Wayne Manor'),
    ('Stark Industries', 1000, 'CRN654', 'davidbrown@example.com', 'USA', 'New York', '654 Fifth Ave');
*/


-- Job_ad
/*
INSERT INTO Job_ad (jdate, title, visibility, jstate, email, country, city, app_address, job_description)
VALUES
('2022-01-01', 'Software Engineer', true, 'open', 'johndoe@example.com', 'USA', 'New York', '123 Main St', 'We are seeking a highly motivated software engineer to join our team.'),
('2022-02-15', 'Marketing Specialist', true, 'open', 'janedoe@example.com', 'USA', 'Los Angeles', '456 Oak Ave', 'We are seeking a creative and data-driven marketing specialist to help us reach new audiences.'),
('2022-03-30', 'Accountant', false, 'closed', 'janedoe@example.com', 'Canada', 'Toronto', '789 Maple St', 'We are seeking an experienced accountant to join our finance team.'),
('2022-04-15', 'Web Designer', true, 'open', 'janedoe@example.com', 'UK', 'London', '456 Elm St', 'We are seeking a talented web designer to help us create engaging and user-friendly websites.'),
('2022-05-01', 'Sales Representative', true, 'open', 'bobsmith@example.com', 'Australia', 'Sydney', '789 Pine St', 'We are seeking an energetic and results-driven sales representative to join our team.'),
('2022-05-02', 'Front-end Developer', true, 'open', 'bobsmith@example.com', 'Australia', 'Sydney', '789 Pine St', 'We are hiring.'),
('2022-05-03', 'Back-end Developer', true, 'open', 'bobsmith@example.com', 'Australia', 'Sydney', '789 Pine St', 'Django.'),
('2022-05-04', 'Driver', true, 'open', 'bobsmith@example.com', 'Australia', 'Sydney', '789 Pine St', 'We are hiring driver.');
*/


-- Post
/*
DO $$ 
DECLARE 
    counter INTEGER := 0; 
		BEGIN 
			    WHILE counter < 600 LOOP 
        INSERT INTO Post (ptext, pstate, pdate, email) 
        SELECT 
            CONCAT('Post ', CAST(ROW_NUMBER() OVER () AS TEXT)),
            CASE WHEN random() < 0.9 THEN 'published' ELSE 'draft' END,
            CURRENT_DATE - (FLOOR(random() * 365) * INTERVAL '1 day'),
            email 
        FROM User_field 
        LIMIT 40; 
        counter := counter + 40; 
    END LOOP; 
END $$;
*/


-- Post_comment
/*
INSERT INTO Post_comment (ctext, cdate, email, PID_FK, cidFK) 
VALUES 
    ('Great post, thanks for sharing!', CURRENT_DATE - 7, 'johndoe@example.com', 1, NULL),
    ('I have a question about this post.', CURRENT_DATE - 5, 'johndoe@example.com', 1, NULL),
    ('I completely agree with you!', CURRENT_DATE - 3, 'janedoe@example.com', 2, NULL),
    ('This post was really helpful, thanks!', CURRENT_DATE - 2, 'bobsmith@example.com', 2, NULL),
    ('Could you provide some more examples?', CURRENT_DATE - 1, 'alicejones@example.com', 2, NULL),
    ('Here is a helpful link I found on this topic.', CURRENT_DATE, 'davidbrown@example.com', 3, NULL),
    ('I think there is a mistake in this post.', CURRENT_DATE - 4, 'amartin@gmail.com', 3, NULL),
    ('Thanks for the great explanation!', CURRENT_DATE - 3, 'esmith@hotmail.com', 3, NULL),
    ('Could you clarify this point for me?', CURRENT_DATE - 2, 'njohnson@yahoo.com', 4, NULL),
    ('I found a typo in this post.', CURRENT_DATE - 1, 'njohnson@yahoo.com', 4, NULL),
    ('This post is very interesting!', CURRENT_DATE, 'odavis@gmail.com', 4, NULL),
    ('I think this post could use some more detail.', CURRENT_DATE - 6, 'lwilson@hotmail.com', 5, NULL),
    ('Thanks for the helpful tips!', CURRENT_DATE - 4, 'smoore@yahoo.com', 5, NULL),
    ('I have a different perspective on this topic.', CURRENT_DATE - 2, 'ebrown@gmail.com', 5, NULL),
    ('I think you missed an important point in this post.', CURRENT_DATE - 1, 'ilee@hotmail.com', 5, NULL),
    ('This post was very useful, thanks!', CURRENT_DATE, 'mgarcia@yahoo.com', 6, NULL),
    ('I had a similar experience, thanks for sharing!', CURRENT_DATE - 5, 'mrodriguez@gmail.com', 6, NULL),
    ('Could you recommend some more resources on this topic?', CURRENT_DATE - 3, 'mrodriguez@gmail.com', 6, NULL),
    ('I think this post is missing some important context.', CURRENT_DATE - 1, 'mrodriguez@gmail.com', 6, NULL),
    ('Thanks for the informative post!', CURRENT_DATE, 'ebrown@gmail.com', 7, NULL),
    ('I have a question about one of the points you made.', CURRENT_DATE - 4, 'odavis@gmail.com', 7, NULL),
    ('I think this post could benefit from some more examples.', CURRENT_DATE - 2, 'amartin@gmail.com', 7, NULL);
*/


-- Job_req
/*
INSERT INTO Job_req (jid, email, reqstate, reqdate, reqtext, reqresume) VALUES
(6, 'amartin@gmail.com', 'pending', '2022-01-15', 'I am interested in the Software Engineer position', 'Attached is my resume.'),
(7, 'esmith@hotmail.com', 'approved', '2022-02-20', 'I am applying for the Accountant position', 'My resume and cover letter are attached.'),
(6, 'njohnson@yahoo.com', 'rejected', '2022-02-01', 'I am not interested in the Software Engineer position', NULL),
(9, 'odavis@gmail.com', 'pending', '2022-03-01', 'I am interested in the Web Designer position', 'Here is a link to my portfolio: www.odavisdesigns.com.'),
(7, 'lwilson@hotmail.com', 'approved', '2022-03-10', 'I am applying for the Accountant position', 'Please see attached documents.'),
(8, 'smoore@yahoo.com', 'pending', '2022-04-01', 'I am interested in the Marketing Specialist position', 'I have experience in social media marketing.'),
(10, 'ebrown@gmail.com', 'approved', '2022-04-15', 'I am applying for the Sales Representative position', 'I have 5 years of sales experience.'),
(11, 'ilee@hotmail.com', 'pending', '2022-05-01', 'I am interested in the Front-end Developer position', 'Here is a link to my GitHub portfolio.'),
(12, 'mgarcia@yahoo.com', 'approved', '2022-05-15', 'I am applying for the Back-end Developer position', 'I have experience with Python and Django.'),
(13, 'mrodriguez@gmail.com', 'rejected', '2022-06-01', 'I am not interested in the Driver position', NULL);
*/

-- Tags
/*
INSERT INTO Tags ( tag, jid_fk) VALUES
('Software Engineer', 6),
('C', 6),
('C++', 6),
('Marketing', 7),
('Specialist', 7),
('Social', 7),
('Accountant', 8),
('Finance', 8),
('Designer', 9),
('Front-End', 9),
('Artist', 9),
('CSS', 9),
('Bootstrap', 9),
('Sales', 10),
('Front-End', 11),
('CSS', 11),
('SASS', 11),
('UI', 11),
('UX', 11),
('Back-End', 12),
('Python', 12),
('Django', 12),
('Web-Server', 12),
('Driver', 13);
*/

-- Images
/*
INSERT INTO Images (url_image, pid_fk) VALUES
('https://example.com/image1.jpg', 1),
('https://example.com/image2.jpg', 1),
('https://example.com/image3.jpg', 2),
('https://example.com/image4.jpg', 2),
('https://example.com/image5.jpg', 3),
('https://example.com/image6.jpg', 3),
('https://example.com/image7.jpg', 4),
('https://example.com/image8.jpg', 4),
('https://example.com/image9.jpg', 5),
('https://example.com/image10.jpg', 5),
('https://example.com/image11.jpg', 6),
('https://example.com/image12.jpg', 6),
('https://example.com/image13.jpg', 7),
('https://example.com/image14.jpg', 7),
('https://example.com/image15.jpg', 8),
('https://example.com/image16.jpg', 8),
('https://example.com/image17.jpg', 9),
('https://example.com/image18.jpg', 9),
('https://example.com/image19.jpg', 10),
('https://example.com/image20.jpg', 10),
('https://example.com/image21.jpg', 11),
('https://example.com/image22.jpg', 11),
('https://example.com/image23.jpg', 12),
('https://example.com/image24.jpg', 12),
('https://example.com/image25.jpg', 13),
('https://example.com/image26.jpg', 13),
('https://example.com/image27.jpg', 14),
('https://example.com/image28.jpg', 14),
('https://example.com/image29.jpg', 15),
('https://example.com/image30.jpg', 15);
*/

-- Skills
/*
INSERT INTO Skills (text_Skills, email) VALUES
('Python', 'amartin@gmail.com'),
('JavaScript', 'amartin@gmail.com'),
('SQL', 'amartin@gmail.com'),
('React', 'amartin@gmail.com'),
('Python', 'esmith@hotmail.com'),
('Java', 'esmith@hotmail.com'),
('C++', 'njohnson@yahoo.com'),
('JavaScript', 'njohnson@yahoo.com'),
('React', 'njohnson@yahoo.com'),
('Python', 'lwilson@hotmail.com'),
('C#', 'lwilson@hotmail.com'),
('SQL', 'lwilson@hotmail.com'),
('Python', 'smoore@yahoo.com'),
('JavaScript', 'smoore@yahoo.com'),
('Ruby', 'ebrown@gmail.com'),
('Python', 'ebrown@gmail.com'),
('SQL', 'ebrown@gmail.com'),
('Java', 'ilee@hotmail.com'),
('JavaScript', 'ilee@hotmail.com'),
('Python', 'mgarcia@yahoo.com'),
('C++', 'mgarcia@yahoo.com'),
('JavaScript', 'mrodriguez@gmail.com'),
('React', 'mrodriguez@gmail.com'),
('SQL', 'mrodriguez@gmail.com');
*/

-- Experiences
/*
INSERT INTO Experience (email, title, details, Company, salary, startdate, enddate)
VALUES
('amartin@gmail.com', 'Software Engineer', 'Developed and maintained software applications', 'ABC Inc.', 75000, '2018-01-01', '2021-06-30'),
('amartin@gmail.com', 'Project Manager', 'Led a team of developers to deliver software projects on time and within budget', 'XYZ Corp.', 85000, '2021-07-01', '2022-12-31'),
('esmith@hotmail.com', 'Marketing Manager', 'Developed and implemented marketing campaigns', 'ABC Inc.', 80000, '2019-02-01', '2022-05-31'),
('esmith@hotmail.com', 'Sales Representative', 'Generated new leads and closed deals', 'XYZ Corp.', 60000, '2022-06-01', '2023-02-28'),
('njohnson@yahoo.com', 'Data Analyst', 'Analyzed data and generated reports', '123 Corp.', 70000, '2020-03-01', '2021-12-31'),
('njohnson@yahoo.com', 'Data Scientist', 'Built and trained machine learning models', '456 Corp.', 90000, '2022-01-01', '2023-03-08'),
('odavis@gmail.com', 'Senior Developer', 'Designed and implemented software solutions', 'ABC Inc.', 100000, '2017-01-01', '2022-03-31'),
('lwilson@hotmail.com', 'IT Manager', 'Managed IT infrastructure and systems', 'XYZ Corp.', 90000, '2018-04-01', '2022-02-28'),
('smoore@yahoo.com', 'Graphic Designer', 'Designed marketing materials and websites', 'ABC Inc.', 60000, '2020-01-01', '2022-12-31'),
('ebrown@gmail.com', 'Product Manager', 'Managed the product lifecycle from ideation to launch', 'XYZ Corp.', 95000, '2019-06-01', '2022-09-30'),
('ilee@hotmail.com', 'Human Resources Manager', 'Managed HR functions including recruiting, onboarding, and performance management', 'ABC Inc.', 85000, '2021-01-01', '2023-03-08'),
('mgarcia@yahoo.com', 'Financial Analyst', 'Analyzed financial data and prepared reports for management', 'XYZ Corp.', 70000, '2022-02-01', '2023-03-08'),
('mrodriguez@gmail.com', 'Customer Service Representative', 'Handled customer inquiries and resolved issues', '123 Corp.', 55000, '2021-03-01', '2022-11-30');
*/

-- Save_post
/*
INSERT INTO Save_post (email, pid_fk)
SELECT U.email, pid
FROM User_field U, Post
ORDER BY random()
LIMIT 500;
*/

-- React

INSERT INTO React (Reaction, email, pid_fk) VALUES
('D', 'janedoe@example.com', 2),
('L', 'bobsmith@example.com', 3),
('D', 'alicejones@example.com', 4),
('L', 'davidbrown@example.com', 5),
('D', 'amartin@gmail.com', 6),
('L', 'esmith@hotmail.com', 7),
('D', 'njohnson@yahoo.com', 8),
('L', 'odavis@gmail.com', 9),
('D', 'lwilson@hotmail.com', 10),
('L', 'smoore@yahoo.com', 11),
('D', 'ebrown@gmail.com', 12),
('L', 'ilee@hotmail.com', 13),
('D', 'mgarcia@yahoo.com', 14),
('L', 'mrodriguez@gmail.com', 15),
('D', 'johndoe@example.com', 1),
('D', 'johndoe@example.com', 2),
('D', 'johndoe@example.com', 3),
('D', 'johndoe@example.com', 4),
('D', 'johndoe@example.com', 5),
('D', 'johndoe@example.com', 6),
('D', 'johndoe@example.com', 7),
('D', 'johndoe@example.com', 8),
('D', 'johndoe@example.com', 9),
('D', 'johndoe@example.com', 10),
('D', 'johndoe@example.com', 11),
('D', 'johndoe@example.com', 12),
('D', 'johndoe@example.com', 13),
('D', 'johndoe@example.com', 14),
('D', 'johndoe@example.com', 15),
('D', 'johndoe@example.com', 16),
('D', 'johndoe@example.com', 17),
('D', 'johndoe@example.com', 18),
('D', 'johndoe@example.com', 19),
('D', 'johndoe@example.com', 20),
('D', 'johndoe@example.com', 21),
('D', 'johndoe@example.com', 22),
('D', 'johndoe@example.com', 23),
('D', 'johndoe@example.com', 24),
('D', 'johndoe@example.com', 25),
('D', 'johndoe@example.com', 26),
('D', 'johndoe@example.com', 27),
('D', 'johndoe@example.com', 28),
('D', 'johndoe@example.com', 29),
('D', 'johndoe@example.com', 30),
('D', 'johndoe@example.com', 31),
('D', 'johndoe@example.com', 32),
('D', 'johndoe@example.com', 33),
('D', 'johndoe@example.com', 34),
('D', 'johndoe@example.com', 35),
('D', 'johndoe@example.com', 36),
('D', 'johndoe@example.com', 37),
('D', 'johndoe@example.com', 38),
('D', 'johndoe@example.com', 39),
('D', 'johndoe@example.com', 40),
('D', 'johndoe@example.com', 41),
('D', 'johndoe@example.com', 42),
('D', 'johndoe@example.com', 43),
('D', 'johndoe@example.com', 44),
('D', 'johndoe@example.com', 45),
('D', 'johndoe@example.com', 46),
('D', 'johndoe@example.com', 47),
('D', 'johndoe@example.com', 48),
('D', 'johndoe@example.com', 49),
('D', 'johndoe@example.com', 50),
('D', 'johndoe@example.com', 51),
('D', 'johndoe@example.com', 52),
('D', 'johndoe@example.com', 53),
('D', 'johndoe@example.com', 54),
('D', 'johndoe@example.com', 55),
('D', 'johndoe@example.com', 56),
('D', 'johndoe@example.com', 57),
('D', 'johndoe@example.com', 58),
('D', 'johndoe@example.com', 59),
('D', 'johndoe@example.com', 60),
('D', 'johndoe@example.com', 61),
('D', 'johndoe@example.com', 62),
('D', 'johndoe@example.com', 63),
('D', 'johndoe@example.com', 64),
('D', 'johndoe@example.com', 65),
('D', 'johndoe@example.com', 66),
('D', 'johndoe@example.com', 67),
('D', 'johndoe@example.com', 68),
('D', 'johndoe@example.com', 69),
('D', 'johndoe@example.com', 70),
('D', 'johndoe@example.com', 71),
('D', 'johndoe@example.com', 72),
('D', 'johndoe@example.com', 73),
('D', 'johndoe@example.com', 74),
('D', 'johndoe@example.com', 75),
('D', 'johndoe@example.com', 76),
('D', 'johndoe@example.com', 77),
('D', 'johndoe@example.com', 78),
('D', 'johndoe@example.com', 79),
('D', 'johndoe@example.com', 80),
('D', 'johndoe@example.com', 81),
('D', 'johndoe@example.com', 82),
('D', 'johndoe@example.com', 83),
('D', 'johndoe@example.com', 84),
('D', 'johndoe@example.com', 85),
('D', 'johndoe@example.com', 86),
('D', 'johndoe@example.com', 87),
('D', 'johndoe@example.com', 88),
('D', 'johndoe@example.com', 89),
('D', 'johndoe@example.com', 90),
('D', 'johndoe@example.com', 91),
('D', 'johndoe@example.com', 92),
('D', 'johndoe@example.com', 93),
('D', 'johndoe@example.com', 94),
('D', 'johndoe@example.com', 95),
('D', 'johndoe@example.com', 96);
