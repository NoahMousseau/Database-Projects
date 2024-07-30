/********************************************************************************
Author: Noah Mousseau
Access ID: hc7739
Assignment: 3
Date: 6/7/2024
Description: A file meant to perform various operations and test commands using the StudentGradeReport table
********************************************************************************/
USE StudentGradeReport;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q1', NULL, NULL);
GO

-- Q1. Using an insert statement to add a new student with the following attributes:
-- StudentID – 101, StudentName – John Doe, Major – Computer Science
MERGE StudentGradeReport AS target
USING (SELECT 101 AS StudentNo, 'John Doe' AS StudentName, 'Computer Science' AS Major, 'N/A' AS CourseNo, 'N/A' AS CourseName, 0 AS InstructorNo, 'N/A' AS InstructorName, 'N/A' AS InstructorLocation, '' AS Grade) AS source
ON (target.StudentNo = source.StudentNo)
WHEN MATCHED THEN 
    UPDATE SET StudentName = source.StudentName, Major = source.Major
WHEN NOT MATCHED THEN
    INSERT (StudentNo, StudentName, Major, CourseNo, CourseName, InstructorNo, InstructorName, InstructorLocation, Grade)
    VALUES (source.StudentNo, source.StudentName, source.Major, source.CourseNo, source.CourseName, source.InstructorNo, source.InstructorName, source.InstructorLocation, source.Grade);
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q2', NULL, NULL);
GO

-- Q2. Using an insert statement to add a new course & instructor with these attributes:
-- InstructorID – 102, InstructorName – Jane Doe, InstructorLocation – Old Main, CourseNum – 505, CourseName – Test CourseName
MERGE StudentGradeReport AS target
USING (SELECT 0 AS StudentNo, 'N/A' AS StudentName, 'N/A' AS Major, '505' AS CourseNo, 'Test CourseName' AS CourseName, 102 AS InstructorNo, 'Jane Doe' AS InstructorName, 'Old Main' AS InstructorLocation, '' AS Grade) AS source
ON (target.CourseNo = source.CourseNo AND target.InstructorNo = source.InstructorNo)
WHEN MATCHED THEN 
    UPDATE SET InstructorName = source.InstructorName, InstructorLocation = source.InstructorLocation, CourseName = source.CourseName
WHEN NOT MATCHED THEN
    INSERT (StudentNo, StudentName, Major, CourseNo, CourseName, InstructorNo, InstructorName, InstructorLocation, Grade)
    VALUES (source.StudentNo, source.StudentName, source.Major, source.CourseNo, source.CourseName, source.InstructorNo, source.InstructorName, source.InstructorLocation, source.Grade);
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q3', NULL, NULL);
GO

-- Q3. Using an insert statement to enroll a student in course with these attributes:
-- StudentID – 101, InstructorID -- 102, CourseNum – 505, Grade – A
MERGE StudentGradeReport AS target
USING (SELECT 101 AS StudentNo, 'John Doe' AS StudentName, 'Engineering' AS Major, '505' AS CourseNo, 'Test CourseName' AS CourseName, 102 AS InstructorNo, 'Jane Doe' AS InstructorName, 'Old Main' AS InstructorLocation, 'A' AS Grade) AS source
ON (target.StudentNo = source.StudentNo AND target.CourseNo = source.CourseNo)
WHEN MATCHED THEN 
    UPDATE SET Grade = source.Grade
WHEN NOT MATCHED THEN
    INSERT (StudentNo, StudentName, Major, CourseNo, CourseName, InstructorNo, InstructorName, InstructorLocation, Grade)
    VALUES (source.StudentNo, source.StudentName, source.Major, source.CourseNo, source.CourseName, source.InstructorNo, source.InstructorName, source.InstructorLocation, source.Grade);
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q4', NULL, NULL);
GO

-- Q4. Creating grade report for this student
SELECT * FROM StudentGradeReport
WHERE StudentNo = 101;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q5', NULL, NULL);
GO

-- Q5. Using an update statement to update InstructorName to ‘Janet Doe’
UPDATE StudentGradeReport
SET InstructorName = 'Janet Doe'
WHERE InstructorNo = 102;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q6', NULL, NULL);
GO

-- Q6. Using an update statement to update Student Major to ‘Engineering’
UPDATE StudentGradeReport
SET Major = 'Engineering'
WHERE StudentNo = 101;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q7', NULL, NULL);
GO

-- Q7. Using a grade report for this student, similar to Q4
SELECT * FROM StudentGradeReport
WHERE StudentNo = 101;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q8', NULL, NULL);
GO

-- Q8. Creating a grade report for all students in this database
SELECT * FROM StudentGradeReport;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q9', NULL, NULL);
GO

-- Q9. Delete statement for StudentNo 1002
DELETE FROM StudentGradeReport
WHERE StudentNo = 1002;
GO

RAISERROR (N'Question %s for CRUD Operations', 10, 1, 'Q10', NULL, NULL);
GO

-- Q10. Creating a grade report for all students
SELECT * FROM StudentGradeReport;
GO
