CREATE DATABASE CodeDB;

USE CodeDB;

CREATE TABLE Employees (
EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
Name VARCHAR(50) NOT NULL
);


CREATE TABLE Device (
DeviceID INT AUTO_INCREMENT PRIMARY KEY,
DeviceName VARCHAR(50) NOT NULL,
EmployeeID INT,
FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Authors (
AuthorsD INT AUTO_INCREMENT PRIMARY KEY,
AuthorsName VARCHAR(50) NOT NULL
);

CREATE   TABLE Books (
BooksID INT AUTO_INCREMENT PRIMARY KEY,
BooksName VARCHAR(50) NOT NULL,
AuthorsD INT,
FOREIGN KEY (AuthorsD) REFERENCES Authors(AuthorsD)
);

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(50)
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(50)
);

CREATE TABLE StudentCourses (
    StudentID INT,
    CourseID INT,
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

-- TABLE LEVEL CONSTRUNTS
CREATE TABLE S (
 s_id int,
 s_name varchar(30),
 constraint s_studentid_pk primary key(s_id)
 );
 
 -- COLUME LEVEL CONSTRANT
CREATE TABLE SS (
s_id INT  PRIMARY KEY,
s_name VARCHAR(30)
);


CREATE TABLE SsS (
s_name VARCHAR(30)
);
-- ALTER CONSTRANT
ALTER TABLE SsS MODIFY s_id INT NOT NULL;

ALTER TABLE SsS ADD CONSTRAINT s_studentid_pk PRIMARY KEY (s_idD);

-- CASCADE Command

CREATE TABLE Coursess (
    c_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

DROP TABLE StudentCourses;

CREATE TABLE StudentCourses (
    student_id INT,
    course_id INT,
    CONSTRAINT student_course_fk FOREIGN KEY (course_id)
        REFERENCES Coursess(c_id)
        ON DELETE CASCADE
);

CREATE TABLE StudentCourses (
    student_id INT,
    course_id INT,
    CONSTRAINT student_course_fk FOREIGN KEY (course_id)
        REFERENCES Courses(c_id)
        ON UPDATE CASCADE
);

CREATE TABLE zamzam (
    s_id INT,
    s_name VARCHAR(30),
    s_email VARCHAR(50) UNIQUE,
    s_gender CHAR(1)
);

CREATE TABLE zamzamm(
    s_id INT,
    s_name VARCHAR(30),
    s_gender CHAR(1),
    s_email VARCHAR(50),  -- add this column
    CONSTRAINT s_email_un UNIQUE(s_email)
);
-- NOT NULL Constraint(TABLE)
CREATE TABLE employeess (
    emp_id INT NOT NULL,
    emp_name VARCHAR(50) NOT NULL,
    emp_email VARCHAR(100),
    emp_salary DECIMAL(10,2) NOT NULL
);
-- NOT NULL Constraint(COLUMN)
CREATE TABLE employeesss (
    emp_id INT,
    emp_name VARCHAR(50),
    emp_email VARCHAR(100)
);

-- NOT NULL Constraint (ALTER)
ALTER TABLE employeesss
MODIFY COLUMN emp_name VARCHAR(50) NOT NULL;

SHOW CREATE TABLE zamzamm;

-- Disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;








