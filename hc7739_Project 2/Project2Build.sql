/********************************************************************************
Author Name: Eunice Shobowale
Create Date: 03/18/2024
Access ID: hd5862
Project: 1
Functionality: DDL scripts
Assumptions: Creating two tables
--------------------------------------------------------------------------------
Author Name:	David L. Colon
Mod Date:		03/19/2024
Access ID:		ef9600
Description:	1) Reworked the Create Database Section 
				2) Additional comenting with flower pots / white space
				3) Additional sample EXEC for insert stored procedure.
				4) Create statements positioned BEFORE actual create / drops
				5) Flower Pots now within print margin.
				6) Unit Test of Creating an Employee
				7) Unit Test of Deleting an Employee
				8) Unit Test of Updating an Employee
				9) Added SET NOCOUNT ON statemets

Assumptions:	Exisiting business rules checks are accurate

*/

--******************************************************************************
-- CREATE HUMAN RESOURCES DATABASE
--******************************************************************************

use master;
go

RAISERROR (N'Creating Database %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'HumanResources', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

-- If the database exists it should be dropped
IF EXISTS (SELECT * FROM sys.databases WHERE [name] = 'HumanResources')
BEGIN
	ALTER DATABASE HumanResources set SINGLE_USER with ROLLBACK Immediate;
	DROP DATABASE HumanResources;
END
GO

-- Create the new HumanResources database
CREATE DATABASE HumanResources;
GO

--******************************************************************************
-- CREATE TABLES
--******************************************************************************

-- Use the new HumanResources database
USE HumanResources;
GO

-------------------------------------------------------------------------------
-- tblEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Table %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'tblEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP TABLE IF EXISTS tblEmployee -- If the table exists it should be dropped

CREATE TABLE tblEmployee (
    EmployeeID [int]			IDENTITY(1,1) NOT NULL,
    EmployeeLastName			NVARCHAR(1000) NOT NULL,
    EmployeeFirstName			NVARCHAR(1000) NOT NULL,
    EmployeeMiddleInitial		NVARCHAR(1) NULL,
    EmployeeDateOfBirth			DATE NOT NULL,
    EmployeeNumber				NVARCHAR(10) NOT NULL,
    EmployeeGender				VARCHAR(1) NOT NULL,
    EmployeeSSN					NVARCHAR(9) NOT NULL,
    EmployeeActiveFlag			INT DEFAULT 1,
    CreatedDate					DATETIME DEFAULT GETDATE() ,
    CreatedBy					NVARCHAR(100) DEFAULT SUSER_NAME() ,
    ModifiedDate				DATETIME,
    ModifiedBy					NVARCHAR(1000)
);

-------------------------------------------------------------------------------
-- tblLogErrors
-------------------------------------------------------------------------------

RAISERROR (N'Creating Table %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'tblLogErrors', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP TABLE IF EXISTS tblLogErrors -- If the table exists it should be dropped

CREATE TABLE [tblLogErrors] (
    [ErrorLogID]				INT IDENTITY(1,1) PRIMARY KEY,
    [ErrorNumber] INT,
    [ErrorSeverity] INT,
    [ErrorState] INT,
    [ErrorProcedure] NVARCHAR(128),
    [ErrorLine] INT,
    [ErrorMessage] NVARCHAR(4000),
    [ErrorUser] NVARCHAR(128),
	[ErrorDateTime] DATETIME
);
GO


--******************************************************************************
-- CREATE STORED PROCEDURES
--******************************************************************************

-------------------------------------------------------------------------------
-- usp_InsertEmployee
-------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS usp_InsertEmployee;
GO

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_InsertEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

CREATE PROCEDURE usp_InsertEmployee
/********************************************************************************
Author Name: Eunice Shobowale
Create Date: 03/18/2024
Parameter 1: @EmployeeLastName
Parameter 2: @EmployeeFirstName
Parameter 3: @EmployeeMiddleInitial
Parameter 4: @EmployeeDateOfBirth
Parameter 5: @EmployeeNumber
Parameter 6: @EmployeeGender
Parameter 7: @EmployeeSSN
Functionality: Make sure no business rules or contstraints are violated.
Assumptions: Create stored procedure usp_InsertEmployee
********************************************************************************/
/* DECLARE @EmployeeID INT
	DECLARE @RC INT
		
		EXEC  @RC  = usp_InsertEmployee 
					'Colon'
					,'David'
					,'L'
					,'08/01/1970'
					,'C123456'
					,'M'
					,'123459696'
					,@EmployeeID

	SELECT @RC
					*/

    @EmployeeLastName NVARCHAR(1000)
    ,@EmployeeFirstName NVARCHAR(1000)
    ,@EmployeeMiddleInitial NVARCHAR(1)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender VARCHAR(1)
    ,@EmployeeSSN	NVARCHAR(9)
	,@EmployeeID	INT  = NULL OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING

   -- DECLARE @EmployeeID int
    DECLARE @CustomErrorMessage NVARCHAR(125)
    DECLARE @CustomErrorNumber int

    BEGIN TRY

-- check for the business rules print out the custom error codes

	IF LEN(@EmployeeMiddleInitial) > 1
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Middle Initial'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

     IF @EmployeeDateOfBirth < DATEADD(YEAR, -65, GETDATE()) OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeGender NOT IN ('M', 'F')
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Gender'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END
        
	IF @EmployeeLastName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeFirstName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing First Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeDateOfBirth IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'Missing DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeSSN IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'SSN is NULL'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeNumber NOT LIKE LEFT(@EmployeeLastName, 1) + '%'
	BEGIN
		SELECT @CustomErrorMessage = 'Employee Number does not start with first letter of Employee Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END


-- inserting into the tbl.Employee that have been created
	INSERT INTO tblEmployee (
			EmployeeLastName
            ,EmployeeFirstName
            ,EmployeeMiddleInitial
            ,EmployeeDateOfBirth
            ,EmployeeNumber
            ,EmployeeGender
            ,EmployeeSSN
	)
	VALUES 
	(
            @EmployeeLastName
            ,@EmployeeFirstName
            ,@EmployeeMiddleInitial
            ,@EmployeeDateOfBirth
            ,@EmployeeNumber
            ,@EmployeeGender
            ,@EmployeeSSN
        );

-- get the employeeid
        SELECT @EmployeeID = @@IDENTITY;
		

		RETURN @EmployeeID;
 END TRY
BEGIN CATCH
--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
		
	END CATCH;
END;
go



-------------------------------------------------------------------------------
-- usp_DeleteEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_DeleteEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO

DROP PROCEDURE IF EXISTS usp_DeleteEmployee;
GO

CREATE PROCEDURE usp_DeleteEmployee

-- Create stored procedure usp_DeleteEmployee which adheres to Stored Procedure Standards
/********************************************************************************
Author Name: Eunice Shobowale
Create Date: 03/18/2024
Parameter 1: @EmployeeID
Functionality: Given and employee id, do a proper delete
Assumptions: Create stored procedure usp_DeleteEmployee
********************************************************************************/
    @EmployeeID INT
AS
BEGIN
	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    DECLARE @ErrorMessage NVARCHAR(125)
    DECLARE @ErrorNumber int

	BEGIN TRY
-- Delete this 
        DELETE 
		FROM tblEmployee 
		WHERE EmployeeID = @EmployeeID;

     
-- Log delete in the tblLogsError table
	INSERT INTO tblLogErrors (
			ErrorMessage
			,ErrorDateTime
		)
        VALUES
		(
			ERROR_MESSAGE()
			,GETDATE()
		);

    END TRY

       BEGIN CATCH
--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
	END CATCH;
END;
GO

-------------------------------------------------------------------------------
-- usp_UpdateEmployee
-------------------------------------------------------------------------------

RAISERROR (N'Creating Stored Procedure %s...', -- Message text.
			10, -- Severity,
			1, -- State,
			'usp_UpdateEmployee', --First Argument
			NULL, -- Second Argument
			NULL); -- third argument.
GO
DROP PROCEDURE IF EXISTS usp_UpdateEmployee;
GO

CREATE PROCEDURE usp_UpdateEmployee
/********************************************************************************
Author Name: Eunice Shobowale
Create Date: 03/18/2024
Parameter 1: @EmployeeID
Parameter 2: @EmployeeLastName
Parameter 3: @EmployeeFirstName
Parameter 4: @EmployeeMiddleInitial
Parameter 5: @EmployeeDateOfBirth
Parameter 6: @EmployeeNumber
Parameter 7: @EmployeeGender
Parameter 8: @EmployeeSSN

Functionality: Make sure no business rules or contstraints are violated.
Assumptions: Create stored procedure usp_UpdateEmployee
*/

/* 
		
		EXEC  usp_UpdateEmployee 
					3
					,'Colon'
					,'Davie'
					,'L'
					,'08/01/1970'
					,'C123456'
					,'M'
					,'123459696'
					,1

	SELECT @RC
					*/

     @EmployeeID INT
    ,@EmployeeLastName VARCHAR(1000)
    ,@EmployeeFirstName VARCHAR(1000)
    ,@EmployeeMiddleInitial CHAR(1)
    ,@EmployeeDateOfBirth DATE
    ,@EmployeeNumber VARCHAR(10)
    ,@EmployeeGender CHAR(1)
    ,@EmployeeSSN NVARCHAR(9)
AS
BEGIN

	SET NOCOUNT ON;

-- USING EXAMPLE GIVEN IN CLASS DECLARE THE FOLLOWING
    DECLARE @CustomErrorMessage NVARCHAR(125)
    DECLARE @CustomErrorNumber int

    BEGIN TRY

-- check for the business rules print out the custom error codes

	IF LEN(@EmployeeMiddleInitial) > 1
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Middle Initial'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

     IF @EmployeeDateOfBirth < DATEADD(YEAR, -65, GETDATE()) OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeGender NOT IN ('M', 'F')
	BEGIN
		SELECT @CustomErrorMessage = 'Invalid Gender'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END
        
	IF @EmployeeLastName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeFirstName IS NULL 
	BEGIN
		SELECT @CustomErrorMessage = 'Missing First Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeDateOfBirth IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'Missing DOB'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeSSN IS NULL
	BEGIN
		SELECT @CustomErrorMessage = 'SSN is NULL'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END

	IF @EmployeeNumber NOT LIKE LEFT(@EmployeeLastName, 1) + '%'
	BEGIN
		SELECT @CustomErrorMessage = 'Employee Number does not start with first letter of Employee Last Name'
			,@CustomErrorNumber = 50000
		RAISERROR (@CustomErrorMessage, -- Message text.
			   16, -- Severity,
			   1, -- State,
				NULL,		-- Second Argument
				NULL);		-- third argument.
	END


-- update the following
	UPDATE tblEmployee
	SET EmployeeLastName = @EmployeeLastName
        ,EmployeeFirstName = @EmployeeFirstName
        ,EmployeeMiddleInitial = @EmployeeMiddleInitial
        ,EmployeeDateOfBirth = @EmployeeDateOfBirth
        ,EmployeeNumber = @EmployeeNumber
        ,EmployeeGender = @EmployeeGender
        ,EmployeeSSN = @EmployeeSSN
       
	WHERE EmployeeID = @EmployeeID;
      
-- Log Update in the tblLogsError
	INSERT INTO tblLogErrors (
			ErrorMessage
			,ErrorDateTime
		)
        VALUES
		(
			ERROR_MESSAGE()
			,GETDATE()
		);



 END TRY
	BEGIN CATCH

--inserting logerrors
		INSERT INTO tblLogErrors (
			ErrorNumber
			,ErrorSeverity
			,ErrorState
			,ErrorProcedure
			,ErrorLine
			,ErrorMessage
			,ErrorUser
			,ErrorDateTime
		)
		SELECT  ErrorNumber = ERROR_NUMBER()
				,ErrorSeverity = ERROR_SEVERITY()
				,ErrorState = ERROR_STATE()
				,ErrorProcedure = ERROR_PROCEDURE()
				,ErrorLine = ERROR_LINE()
				,ErrorMessage = ERROR_MESSAGE()
				,ErrorUser = SYSTEM_USER
				,GETDATE()
		
	END CATCH;
END;

GO

-- CREATE SOME TEST DATA
EXEC  usp_InsertEmployee 
					'Colon'
					,'Joseph'
					,'J'
					,'11/21/1970'
					,'C111111'
					,'M'
					,'123459697'


EXEC  usp_InsertEmployee 
					'Colon'
					,'Renee'
					,'A'
					,'08/21/1981'
					,'C222222'
					,'F'
					,'123459698'


EXEC  usp_InsertEmployee 
					'Colon'
					,'Damian'
					,''
					,'12/21/1970'
					,'C333333'
					,'M'
					,'123459699'

--	CREATING 5 NEW EMPLOYEE RECORDS FOR TESTING PURPOSES
EXEC usp_InsertEmployee 
    'Smith'
	, 'Nicholas'
	, 'C'
	, '01/01/1990'
	, 'S111111'
	, 'M'
	, '987654321'

EXEC usp_InsertEmployee 
    'Excelleris'
	, 'Rachel'
	, 'G'
	, '02/02/1987'
	, 'R111111'
	, 'F'
	, '123456780'

EXEC usp_InsertEmployee 
    'Johnson'
	, 'Steve'
	, 'H'
	, '05/07/1988'
	, 'J111111'
	, 'M'
	, '167802345'

EXEC usp_InsertEmployee 
    'Stevens'
	, 'Sam'
	, 'A'
	, '10/11/1990'
	, 'S222222'
	, 'F'
	, '123894080'

EXEC usp_InsertEmployee 
    'Washington'
	, 'Hannah'
	, 'J'
	, '07/12/1992'
	, 'W111111'
	, 'F'
	, '4783940035'

GO

--	AFTER REBUILDING DATABASE AND INSERTING THE 5 NEW RECORDS, CREATES A BACKUP OF THE DATABASE
BACKUP DATABASE HumanResources
TO DISK = 'D:\Noah''s Stuff\College\Year 4 Summer Semester\Database Management\hc7739_Project 2\HumanResourcesBaseline.bak';
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 2024-07-16
Functionality: Update ModifiedDate and ModifiedBy fields when an employee record is updated
Assumptions: Trigger should only run on updates, not on inserts
****************************************************************/
CREATE TRIGGER trgEmployeeUpdate
ON tblEmployee
AFTER UPDATE
AS
BEGIN
    -- CHECK IF CREATEDDATE IS NOT NULL TO BE SURE THAT IT'S AN UPDATE, NOT AN INSERT
    IF EXISTS (SELECT * FROM Inserted WHERE CreatedDate IS NOT NULL)
    BEGIN
		-- UPDATE MODIFIEDDATE AND MODIFIEDBY FIELDS
        UPDATE tblEmployee
        SET ModifiedDate = GETDATE(), ModifiedBy = SUSER_NAME()
        FROM tblEmployee e
        INNER JOIN Inserted i ON e.EmployeeID = i.EmployeeID;
    END
END;
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 2024-07-16
Functionality: Perform logical delete by setting EmployeeActiveFlag to 0 instead of physical delete
Assumptions: Trigger should handle both single and multiple row deletions
****************************************************************/
CREATE TRIGGER trgEmployeeDelete
ON tblEmployee
INSTEAD OF DELETE
AS
BEGIN
	-- PERFORM LOGICAL DELETE BY SETTING EMPLOYEEACTIVEFLAG TO 0
    UPDATE tblEmployee
    SET EmployeeActiveFlag = 0
    FROM tblEmployee e
    INNER JOIN Deleted d ON e.EmployeeID = d.EmployeeID;
END;
GO

--	CREATING EMPLOYEE HISTORY TABLE
CREATE TABLE tblEmployeeHistory (
    EmployeeHistoryID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    EmployeeLastName NVARCHAR(1000),
    EmployeeFirstName NVARCHAR(1000),
    EmployeeMiddleInitial NVARCHAR(1),
    EmployeeDateOfBirth DATE,
    EmployeeNumber NVARCHAR(10),
    EmployeeGender CHAR(1),
    EmployeeSSN NVARCHAR(9),
    EmployeeActiveFlag INT,
    CreatedDate DATETIME,
    CreatedBy NVARCHAR(100),
    ModifiedDate DATETIME,
    ModifiedBy NVARCHAR(1000)
);
GO

--	ALTERING trgEmployeeUpdate TRIGGER TO STORE A CPOY OF THE RECORD IN THE EMPLOYEE HISTORY TABLE BEFORE UPDATES
ALTER TRIGGER trgEmployeeUpdate
ON tblEmployee
AFTER UPDATE
AS
BEGIN
	-- IF INSERTED.CREATEDDATE IS NOT NULL, THEN PROCEED TO STORE THE OLD RECORD IN HISTORY TABLE
    IF NOT EXISTS (SELECT * FROM Inserted WHERE CreatedDate IS NULL)
    BEGIN
		-- INSERT OLD RECORD INTO EMPLOYEE HISTORY TABLE
        INSERT INTO tblEmployeeHistory (
            EmployeeID, EmployeeLastName, EmployeeFirstName, EmployeeMiddleInitial, 
            EmployeeDateOfBirth, EmployeeNumber, EmployeeGender, EmployeeSSN, 
            EmployeeActiveFlag, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
        )
        SELECT 
            d.EmployeeID, d.EmployeeLastName, d.EmployeeFirstName, d.EmployeeMiddleInitial, 
            d.EmployeeDateOfBirth, d.EmployeeNumber, d.EmployeeGender, d.EmployeeSSN, 
            d.EmployeeActiveFlag, d.CreatedDate, d.CreatedBy, GETDATE(), SUSER_NAME()
        FROM Deleted d;

		-- UPDATE MODIFIEDDATE AND MODIFIEDBY FIELDS IN THE MAIN TABLE
        UPDATE tblEmployee
        SET ModifiedDate = GETDATE(), ModifiedBy = SUSER_NAME()
        FROM tblEmployee e
        INNER JOIN Inserted i ON e.EmployeeID = i.EmployeeID;
    END
END;
GO

--	CHANGING trgEmployeeDelete TRIGGER TO STORE A COPY OF THE RECORD TO BE DELETED IN THE EMPLOYEE HISTORY TABLE BEFORE THE DELETE OPERATION COMPLETES
ALTER TRIGGER trgEmployeeDelete
ON tblEmployee
INSTEAD OF DELETE
AS
BEGIN
	-- INSERT RECORD TO BE DELETED INTO EMPLOYEE HISTORY TABLE
    INSERT INTO tblEmployeeHistory (
        EmployeeID, EmployeeLastName, EmployeeFirstName, EmployeeMiddleInitial, 
        EmployeeDateOfBirth, EmployeeNumber, EmployeeGender, EmployeeSSN, 
        EmployeeActiveFlag, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
    )
    SELECT 
        d.EmployeeID, d.EmployeeLastName, d.EmployeeFirstName, d.EmployeeMiddleInitial, 
        d.EmployeeDateOfBirth, d.EmployeeNumber, d.EmployeeGender, d.EmployeeSSN, 
        d.EmployeeActiveFlag, d.CreatedDate, d.CreatedBy, GETDATE(), SUSER_NAME()
    FROM Deleted d;

	-- UPDATE EMPLOYEEACTIVEFLAG TO 0 IN THE MAIN TABLE
    UPDATE tblEmployee
    SET EmployeeActiveFlag = 0
    FROM tblEmployee e
    INNER JOIN Deleted d ON e.EmployeeID = d.EmployeeID;
END;
GO

--	CREATE AND DEMONSTRATE INSERTION OF NEW EMPLOYEE
EXEC usp_InsertEmployee 
    'Taylor', 'Chris', 'M', '1988-07-22', 'T456789', 'M', '456789123', NULL;

--	UPDATING 3 EXISTING EMPLOYEE RECORDS
EXEC usp_UpdateEmployee 
    @EmployeeID = 4,
    @EmployeeLastName = 'Smith',
    @EmployeeFirstName = 'Nicholas',
    @EmployeeMiddleInitial = 'C',
    @EmployeeDateOfBirth = '1985-06-15',
    @EmployeeNumber = 'S132645',
    @EmployeeGender = 'M',
    @EmployeeSSN = '123456789';

EXEC usp_UpdateEmployee 
    @EmployeeID = 6,
    @EmployeeLastName = 'Stevens',
    @EmployeeFirstName = 'Sam',
    @EmployeeMiddleInitial = 'A',
    @EmployeeDateOfBirth = '1990-10-11',
    @EmployeeNumber = 'S222444',
    @EmployeeGender = 'F',
    @EmployeeSSN = '432194080';

EXEC usp_UpdateEmployee 
    @EmployeeID = 7,
    @EmployeeLastName = 'Washington',
    @EmployeeFirstName = 'Hannah',
    @EmployeeMiddleInitial = 'J',
    @EmployeeDateOfBirth = '1992-07-12',
    @EmployeeNumber = 'W111222',
    @EmployeeGender = 'F',
    @EmployeeSSN = '4475840035';

GO

--	PERFORMING A SECOND UPDATE ON HANNAH WASHINGTON EMPLOYEE RECORD
EXEC usp_UpdateEmployee 
    @EmployeeID = 7,
    @EmployeeLastName = 'Washington',
    @EmployeeFirstName = 'Hannah',
    @EmployeeMiddleInitial = 'J',
    @EmployeeDateOfBirth = '1992-07-12',
    @EmployeeNumber = 'W222333',
    @EmployeeGender = 'F',
    @EmployeeSSN = '4475840035';

--	LOGICALLY DELETE AN EMPLOYEE
EXEC usp_DeleteEmployee 1;

--	FINAL BACKUP
BACKUP DATABASE HumanResources 
TO DISK = 'D:\Noah''s Stuff\College\Year 4 Summer Semester\Database Management\hc7739_Project 2\HumanResourcesFinal.bak';
