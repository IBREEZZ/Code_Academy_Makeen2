-- create the database
CREATE DATABASE TMS;

-- use the database
USE TMS;

-- create STUDENT table
CREATE TABLE STUDENT (
    st_id INT(6),
    st_major CHAR(30),
    st_cohort INT(4) NOT NULL,
    CONSTRAINT students_pk PRIMARY KEY (st_id),
    CONSTRAINT student_id_positive CHECK (st_id > 0)
);

-- create EMPLOYEE/INSTUCTOR table 
CREATE TABLE EMPLOYEE (
    em_id INT(6),
    em_office CHAR(4) NOT NULL,
    em_ext INT(4) ,
    CONSTRAINT employee_ext_chk CHECK (em_ext > 1000),
    CONSTRAINT employee_pk PRIMARY KEY (em_id),
    CONSTRAINT employee_id_positive CHECK (em_id > 0)
);


-- create COLLEGE table
CREATE TABLE COLLEGE (
    cl_code CHAR(3),
    cl_name CHAR(40) NOT NULL,
    cl_dean CHAR(30) ,
    CONSTRAINT college_pk PRIMARY KEY (cl_code)
);

-- create DEPARTMENT table 
CREATE TABLE department  (
dp_code character(4),
dp_name varchar(40) NOT NULL,
dp_hod varchar(30),
dp_col character(3), 
constraint department_pk_dpcode PRIMARY  KEY (dp_code),
constraint department_fk_dpcol FOREIGN KEY (dp_col) 
REFERENCES college (cl_code)
);

-- create BORROWER table 
CREATE TABLE BORROWER (
    br_id NUMERIC(6),
    br_name CHAR(30) NOT NULL,
    br_dept CHAR(4) ,
    br_mobile CHAR(8),
    br_city CHAR(20),
    br_house CHAR(20),
    br_type CHAR(1),
    CONSTRAINT borrower_mobile_chk CHECK (br_mobile >= 9000),
    CONSTRAINT borrower_pk PRIMARY KEY (br_id),
    CONSTRAINT borrower_id_positive CHECK (br_id > 0),
    CONSTRAINT borrower_type_chk CHECK (br_type IN ('S', 'E')),
    CONSTRAINT borrower_col_fk FOREIGN KEY (br_dept) REFERENCES DEPARTMENT(DP_code)
);

-- create BOOK table 
CREATE TABLE book (
bk_id numeric(6),
bk_title varchar(50) NOT NULL,
bk_edition numeric(2),
bk_ofPages numeric(4),
bk_totalCopies numeric(5),
bk_remCopies numeric(5),
constraint book_pk_bkid PRIMARY  KEY (bk_id),
constraint book_ch_bkid CHECK (bk_id > 0),
constraint book_ch_bkofPages CHECK (bk_ofPages > 0)
);

-- create bookTopic table
CREATE TABLE bookTopic (
tp_bkid numeric(6),
tp_desc varchar(30) NOT NULL,
constraint bookTopic_fk_tpBkID FOREIGN KEY (tp_bkid) 
REFERENCES book (bk_id)
);  

-- create course table
CREATE TABLE course (
cr_code character(8),
cr_title varchar(40) NOT NULL,
cr_CH numeric(2),
cr_ofSec numeric(2),
cr_dept character(4),
constraint course_pk_crcode PRIMARY  KEY (cr_code),
constraint course_ch_crCH CHECK (cr_CH > 0),
constraint course_ch_crofSec CHECK (cr_ofSec > 0),
constraint course_fk_crDept FOREIGN KEY (cr_dept) 
REFERENCES DEPARTMENT (DP_code)
);

-- create LINK table
CREATE TABLE CBlink (
li_crCode character(8),
li_bkId numeric(6),
li_usage character(1),
constraint CBlink_ch_liUsage CHECK (li_usage IN ('T','R')),
constraint CBlink_fk_liCrCode FOREIGN KEY (li_crCode) 
REFERENCES course (cr_code),
constraint CBlink_fk_liBkId FOREIGN KEY (li_bkID) 
REFERENCES book (bk_id)
);


-- create regist table
CREATE TABLE regist (
re_brID numeric(6),
re_crCode character(8),
re_semester character(6) NOT NULL,
constraint regist_fk_reBrID FOREIGN KEY (re_brID) 
REFERENCES borrower (br_id),
constraint regist_fk_reCrCode FOREIGN KEY (re_crCode) 
REFERENCES course (cr_code)
);  


-- create issuing table
CREATE TABLE issuing (
is_brID numeric(6),
is_bkID numeric(6),
is_dateTaken DATE  NOT NULL,
is_dateReturn DATE,
constraint issuning_ch_isDataReturn CHECK (is_dateReturn >= is_dateTaken),
constraint issuing_fk_isBrID FOREIGN KEY (is_brID) 
REFERENCES borrower (br_id),
constraint issuing_fk_isBkID FOREIGN KEY (is_bkID) 
REFERENCES book (bk_id)
);

-- INSERT FOR COLLEGE
INSERT INTO college VALUES('COM', 'Economy', 'Prof. Fahim');
INSERT INTO college VALUES('SCI', 'Science', 'Prof. Salma');
INSERT INTO college VALUES('EDU', 'Education', 'Dr. Hamad');
INSERT INTO college VALUES('ART', 'Arts', 'Dr. Abdullah');


INSERT INTO department VALUES('INFS','Information Systems','Dr. Kamla','COM');
INSERT INTO department VALUES('FINA','Finance','Dr. Salim','COM');
INSERT INTO department VALUES('COMP','Computer Science','Dr. Zuhoor','SCI');
INSERT INTO department VALUES('BIOL','Biology','Dr. Othman','SCI');
INSERT INTO department VALUES('HIST','History','Dr. Said','EDU');
INSERT INTO department VALUES('CHEM', 'Chemistry', 'Dr. Alaa', 'SCI');

INSERT INTO borrower VALUES (92120,'Ali','INFS',99221133,'Seeb','231','S');
INSERT INTO borrower VALUES (10021,'Said','INFS',91212129,'Seeb','100','S');
INSERT INTO borrower VALUES (10023,'Muna','FINA', NULL, 'Barka','12','S');
INSERT INTO borrower VALUES (3000,'Mohammed','COMP',90000009,'Seeb','777','E');
INSERT INTO borrower VALUES (4000,'Nasser','INFS',99100199,'Sur','11','E');



INSERT INTO student VALUES(92120,'INFS',2012);
INSERT INTO student VALUES(10021,'INFS',2015);
INSERT INTO student VALUES(10023,'FINA',2015);



INSERT INTO employee VALUES(3000,'12',2221);
INSERT INTO employee VALUES(4000,'15',1401);



INSERT INTO book VALUES(1001,'Database1',2,450,150,65);
INSERT INTO book VALUES(1002,'Database2',3,300,100,100);
INSERT INTO book VALUES(2001,'Intro. to Finanace',1,300,75,40);
INSERT INTO book VALUES(3001,'Basic Op Mgmt',1,320,100,77);
INSERT INTO book VALUES(3002,'Chemistry Book',2,500,100,80);
INSERT INTO book VALUES(4001,'Biology',1,345,100,100);
INSERT INTO book VALUES(3003,'Management I',2,560,44,34);
INSERT INTO book VALUES(1003,'Java Prog.',3,555,50,50);



INSERT INTO bookTopic VALUES (1001,'Basic DB Skills');
INSERT INTO bookTopic VALUES (1001,'ERD');
INSERT INTO bookTopic VALUES (1001,'EERD');
INSERT INTO bookTopic VALUES (1002,'SQL');
INSERT INTO bookTopic VALUES (1002,'Pl/SQL');
INSERT INTO bookTopic VALUES (3001,'Management Skills');



INSERT INTO course VALUES('COMP4201', 'Database1', 3, 1,'COMP');
INSERT INTO course VALUES('COMP4202', 'Database2', 3, 2,'COMP');
INSERT INTO course VALUES('BIOL1000', 'Intro. To Biology', 3, 5,'BIOL');
INSERT INTO course VALUES('CHEM2000', 'Advanced Chemistry', 2, 2,'CHEM');



INSERT INTO CBlink VALUES('COMP4201',1001,'T');
INSERT INTO CBlink VALUES('COMP4201',1002,'R');
INSERT INTO CBlink VALUES('COMP4202',1002,'T');
INSERT INTO CBlink VALUES('BIOL1000',4001,'T');
INSERT INTO CBlink VALUES('CHEM2000',3002,'R');



INSERT INTO regist VALUES(92120,'COMP4201','FL2015');
INSERT INTO regist VALUES(10021,'COMP4202','FL2015');
INSERT INTO regist VALUES(92120,'BIOL1000','FL2015');
INSERT INTO regist VALUES(92120,'COMP4202','FL2016');
INSERT INTO regist VALUES(10021,'CHEM2000','FL2016');



INSERT INTO issuing VALUES(92120, 1001, '01-Sep-2015', '30-Oct-2015');
INSERT INTO issuing VALUES(10021, 1002, '30-Oct-2016', NULL);
INSERT INTO issuing VALUES(92120, 1002, '21-Feb-2015', '01-Jan-2016');
INSERT INTO issuing VALUES(92120, 3002, '30-Mar-2016', NULL);
INSERT INTO issuing VALUES(10021, 3002, '01-Dec-2014', NULL);


-- Insert rows
INSERT INTO STUDENT (st_id, st_major, st_cohort) VALUES
(99999, 'INFS', 2023),
(88888, 'INFS', 2024);

-- Query data
SELECT st_id, st_major,st_cohort FROM STUDENT;

-- updating
UPDATE STUDENT
SET st_major='MATH'
WHERE st_id=10023;

SELECT * FROM STUDENT;

UPDATE BORROWER
SET br_mobile=999999
WHERE br_id=10023;

SELECT * FROM BORROWER;

-- subsitution variables
SET @st_id = 33333;
SET @st_major = 'IT';
SET @st_cohort = 2025;

INSERT INTO STUDENT (st_id, st_major, st_cohort)
VALUES (@st_id, @st_major, @st_cohort);


SELECT * FROM STUDENT;


SET @st_id = 12345;
SET @st_cohort = 2024;

INSERT INTO STUDENT (st_id, st_cohort)
VALUES (@st_id, @st_cohort);

SELECT * FROM STUDENT;

UPDATE BORROWER
SET br_mobile=br_mobile - 100000
WHERE br_id=10023;

select * FROM BORROWER;


-- subquery (USING JOIN)
UPDATE BORROWER AS b
JOIN (
  SELECT br_mobile FROM BORROWER WHERE br_id = 10023
) AS temp
SET b.br_mobile = temp.br_mobile
WHERE b.br_id = 3000;

select * FROM BORROWER;


-- UPDATE multiple column

UPDATE BORROWER
SET br_mobile = 777777,
    br_dept = 'COMP'
WHERE br_id = 10021; 

select * FROM BORROWER;

-- Deleting Rows
DELETE FROM BORROWER
WHERE br_id =3000;

select * FROM BORROWER;

SELECT br_city AS 'city' , br_type
FROM BORROWER;

-- Using Arithmetic Operations
SELECT br_name, br_mobile+1000000 FROM BORROWER;
SELECT br_name, br_mobile-1000000 FROM BORROWER;

-- Displaying Distinct Rows
SELECT DISTINCT br_id
FROM BORROWER;

-- Select specific number of rows
SELECT  * FROM BORROWER
LIMIT  3;

SELECT  br_name FROM BORROWER
LIMIT  3;


SELECT  br_name,br_mobile FROM BORROWER
LIMIT  5;

SELECT * FROM BORROWER;

SELECT * FROM BORROWER
WHERE BR_ID >= ANY (SELECT BR_ID FROM
BORROWER WHERE BR_ID BETWEEN 1 AND 20000);

SELECT * FROM BORROWER
WHERE BR_ID < ALL (SELECT BR_ID FROM
BORROWER WHERE BR_ID BETWEEN 4000 AND 10023);

SELECT * FROM BORROWER;

SELECT * FROM BORROWER
WHERE br_name LIKE '__I%';


SELECT * FROM BORROWER
WHERE br_name NOT LIKE '__I%';

-- Create product_types table
CREATE TABLE product_types (
    product_type_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);
 SELECT * FROM product_types;

-- Create products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    product_type_id INT,
    FOREIGN KEY (product_type_id) REFERENCES product_types(product_type_id)
);
 SELECT * FROM productS;
 
-- Insert into product_types
INSERT INTO product_types (name) VALUES
('Electronics'),
('Clothing'),
('Books');

-- Insert into products
INSERT INTO products (name, product_type_id) VALUES
('Laptop', 1),
('T-Shirt', 2),
('Novel', 3),
('Headphones', 1);

SELECT p.name, pt.name
FROM products p, product_types pt
WHERE p.product_type_id = pt.product_type_id
ORDER BY p.name;

CREATE TABLE namess (
    f_name VARCHAR(100) NOT NULL,
    l_name VARCHAR(100) NOT NULL
);

INSERT INTO namess (f_name , l_name) VALUES
('IBREEZ','SAID'),
('ZAMZAM','SAID'),
('IMAN','ABDULLAH');

SELECT concat(f_name ,' ' , l_name)
as full_name FROM namess;

SELECT concat(product_type_id ,' ' , name)
as id_name FROM product_types;

SELECT Dp_Col, COUNT(dp_name) AS Dept_Count
FROM department
GROUP BY Dp_Col
HAVING COUNT(dp_name) > 1
ORDER BY Dept_Count DESC;


