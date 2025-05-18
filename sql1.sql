-- create the database
CREATE DATABASE CodeAcademyDB;

-- use the database
USE CodeAcademyDB;

-- create the students tables
CREATE TABLE Student (
StudentID INT AUTO_INCREMENT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
Lastname VARCHAR(50) NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL,
EnrollmentDate DATE NOT NULL
);

DESC Student;

-- create the table using AS
CREATE TABLE MyStudent  AS (
SELECT StudentID,FirstName,Email
FROM Student
);

-- using  *
SELECT * FROM Student;

-- TO DELET TABLE
DROP  TABLE MyStudent;

TRUNCATE TABLE Student;

-- rename the table 
RENAME TABLE Student TO New_Student;

ALTER TABLE New_Student 
ADD (ext INT(5));

DESC New_Student;

ALTER TABLE New_Student 
MODIFY COLUMN FirstName VARCHAR(40);