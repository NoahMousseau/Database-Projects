/********************************************************************************
Author: Noah Mousseau
Access ID: hc7739
Assignment: 3
Date: 6/7/2024
Description: A file meant to utilize the StudentGradeReport table in order to 
			 load 4 example items into it
********************************************************************************/

--**************************************************************************************
-- USE statement to indicate using StudentGradeReport
--**************************************************************************************
USE StudentGradeReport;
GO

--**************************************************************************************
-- RAISERROR statement to indicate to user table is being loaded
--**************************************************************************************
RAISERROR (N'Loading Table StudentGradeReport...', 10, 1, N'StudentGradeReport', NULL, NULL);
GO

--**************************************************************************************
-- LOAD StudentGradeReport Table with sample data
--**************************************************************************************
INSERT INTO StudentGradeReport (StudentNo, StudentName, Major, CourseNo, CourseName, InstructorNo, InstructorName, InstructorLocation, Grade)
VALUES
  (1001, 'Noah Mousseau', 'Computer Science', 'CS-1200', 'Introduction to Programming', 2001, 'Prof. Jones', 'BH-312', 'A'),
  (1002, 'Dave Johnson', 'Mathematics', 'MATH-2020', 'Calculus I', 3002, 'Prof. Miller', 'SC-205', 'B'),
  (1003, 'Charlie Davidson', 'Engineering', 'ENGR-3020', 'Statics', 4003, 'Prof. Brown', 'ENG-101', 'C'),
  (1004, 'John Williams', 'English', 'ENGL-1040', 'English Composition', 5004, 'Prof. Garcia', 'FA-102', 'A');
GO