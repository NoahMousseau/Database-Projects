/********************************************************************************
Author: Noah Mousseau
Access ID: hc7739
Assignment: 3
Date: 6/7/2024
Description: A file meant to create a database and table for Student Grade Reports
********************************************************************************/

--**************************************************************************************
-- CREATE StudentGradeReport Database
--**************************************************************************************
CREATE DATABASE StudentGradeReport;
GO

USE StudentGradeReport;
GO

--**************************************************************************************
-- DROP TABLE if it already exists
--**************************************************************************************
DROP TABLE IF EXISTS StudentGradeReport;

--**************************************************************************************
-- CREATE StudentGradeReport Table
--**************************************************************************************
CREATE TABLE StudentGradeReport (
  StudentNo           INT PRIMARY KEY,
  StudentName        NVARCHAR(50) NOT NULL,
  Major               NVARCHAR(50) NOT NULL,
  CourseNo            NVARCHAR(20) NOT NULL,
  CourseName          NVARCHAR(50) NOT NULL,
  InstructorNo        INT,
  InstructorName     NVARCHAR(50),
  InstructorLocation NVARCHAR(50),
  Grade               CHAR(2) -- Can be 'A', 'B', 'C', 'D', or 'F'
);


--**************************************************************************************
-- Generates a message to indicate StudentGradeReport is being created
--**************************************************************************************
RAISERROR (N'Creating Table StudentGradeReport...', 10, 1, N'StudentGradeReport', NULL, NULL);
GO