--Commands to instruct sql to use correct database
USE HumanResources;
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 6/22/2024
Parameter 1: @EmployeeLastName
Parameter 2: @EmployeeFirstName
Parameter 3: @EmployeeMiddleInitial
Parameter 4: @EmployeeDateOfBirth
Parameter 5: @EmployeeNumber
Parameter 6: @EmployeeGender
Parameter 7: @EmployeeSSN
Functionality: Inserts a new employee record and logs any errors.
Assumptions: Assumes input data is provided correctly.
****************************************************************/
--Do not create procedure if it already exists
IF OBJECT_ID('usp_InsertEmployee', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_InsertEmployee;
END
GO

CREATE PROCEDURE usp_InsertEmployee
    @EmployeeLastName NVARCHAR(50),
    @EmployeeFirstName NVARCHAR(50),
    @EmployeeMiddleInitial CHAR(1),
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber CHAR(7),
    @EmployeeGender CHAR(1),
    @EmployeeSSN CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;

    --Validate Employee Number format
    DECLARE @ExpectedEmployeeNumber NVARCHAR(7);
    SET @ExpectedEmployeeNumber = LEFT(@EmployeeLastName, 1) + RIGHT('000000' + @EmployeeNumber, 6);

    IF @EmployeeNumber <> @ExpectedEmployeeNumber
    BEGIN
        RAISERROR('Employee Number must start with the first letter of Employee Last Name followed by 6 digits.', 16, 1);
        RETURN; --Exit procedure
    END

    --Check for reasonable date of birth
    IF @EmployeeDateOfBirth < '1900-01-01' OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
    BEGIN
        RAISERROR('Employee Date of Birth must be between January 1, 1900 and 18 years ago.', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Employee Gender
    IF @EmployeeGender NOT IN ('M', 'F') OR @EmployeeGender IS NULL
    BEGIN
        RAISERROR('Employee Gender must be specified as either ''M'' (Male) or ''F'' (Female).', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Employee Middle Initial
    IF @EmployeeMiddleInitial IS NULL
    BEGIN
        RAISERROR('Employee Middle Initial must not be NULL.', 16, 1);
        RETURN; --Exit procedure
    END

    IF LEN(@EmployeeMiddleInitial) <> 1
    BEGIN
        RAISERROR('Employee Middle Initial must be exactly 1 character.', 16, 1);
        RETURN; --Exit procedure
    END

    BEGIN TRY
        INSERT INTO tblEmployee (
            EmployeeLastName,
            EmployeeFirstName,
            EmployeeMiddleInitial,
            EmployeeDateOfBirth,
            EmployeeNumber,
            EmployeeGender,
            EmployeeSSN,
            CreateDate,
            CreatedBy
        ) VALUES (
            @EmployeeLastName,
            @EmployeeFirstName,
            @EmployeeMiddleInitial,
            @EmployeeDateOfBirth,
            @EmployeeNumber,
            @EmployeeGender,
            @EmployeeSSN,
            GETDATE(),   --Capture current date
            SYSTEM_USER  --Capture current user
        );

    END TRY
    BEGIN CATCH
        DECLARE @ErrorNumber INT = ERROR_NUMBER(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE(),
                @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorUser NVARCHAR(128) = SYSTEM_USER;

        --Log error
        INSERT INTO tblLogErrors (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorUser
        ) VALUES (
            @ErrorNumber,
            @ErrorSeverity,
            @ErrorState,
            @ErrorProcedure,
            @ErrorLine,
            @ErrorMessage,
            @ErrorUser
        );

        --Raise custom error with code 50000
        RAISERROR('Invalid middle initial, date of birth, gender, or missing first/last name.', 50000, 1);
    END CATCH;
END;
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 6/22/2024
Parameter 1: @EmployeeID
Functionality: Deletes an employee record by EmployeeID and logs any errors.
Assumptions: Assumes EmployeeID is valid and exists.
****************************************************************/
--Do not create procedure if it already exists
IF OBJECT_ID('usp_DeleteEmployee', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_DeleteEmployee;
END
GO

CREATE PROCEDURE usp_DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM tblEmployee
        WHERE EmployeeID = @EmployeeID;

        --Log successful delete
        INSERT INTO tblLogErrors (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorUser
        ) VALUES (
            0,
            0,
            0,
            'usp_DeleteEmployee',
            0,
            'Employee deleted successfully.',
            SYSTEM_USER
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNumber INT = ERROR_NUMBER(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE(),
                @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorUser NVARCHAR(128) = SYSTEM_USER;

        --Log error
        INSERT INTO tblLogErrors (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorUser
        ) VALUES (
            @ErrorNumber,
            @ErrorSeverity,
            @ErrorState,
            @ErrorProcedure,
            @ErrorLine,
            @ErrorMessage,
            @ErrorUser
        );

        --Raise custom error with code 50000
        RAISERROR('Invalid middle initial, date of birth, gender, or missing first/last name.', 50000, 1);
    END CATCH;
END;
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 6/22/2024
Parameter 1: @EmployeeID
Parameter 2: @EmployeeLastName
Parameter 3: @EmployeeFirstName
Parameter 4: @EmployeeMiddleInitial
Parameter 5: @EmployeeDateOfBirth
Parameter 6: @EmployeeNumber
Parameter 7: @EmployeeGender
Parameter 8: @EmployeeSSN
Parameter 9: @EmployeeActiveFlag
Functionality: Updates an employee record by EmployeeID and logs any errors.
Assumptions: Assumes EmployeeID is valid and exists.
****************************************************************/
--Do not create procedure if it already exists
IF OBJECT_ID('usp_UpdateEmployee', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_UpdateEmployee;
END
GO

CREATE PROCEDURE usp_UpdateEmployee
    @EmployeeID INT,
    @EmployeeLastName NVARCHAR(50),
    @EmployeeFirstName NVARCHAR(50),
    @EmployeeMiddleInitial CHAR(1),
    @EmployeeDateOfBirth DATE,
    @EmployeeNumber CHAR(7),
    @EmployeeGender CHAR(1),
    @EmployeeSSN CHAR(9),
    @EmployeeActiveFlag BIT
AS
BEGIN
    SET NOCOUNT ON;

    --Validate First Name, Last Name, and Middle Initial
    IF @EmployeeFirstName IS NULL OR @EmployeeLastName IS NULL
    BEGIN
        RAISERROR('First name and last name must not be NULL.', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Employee Date of Birth
    IF @EmployeeDateOfBirth < '1900-01-01' OR @EmployeeDateOfBirth > DATEADD(YEAR, -18, GETDATE())
    BEGIN
        RAISERROR('Employee Date of Birth must be between January 1, 1900 and 18 years ago.', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Middle Initial
	IF @EmployeeMiddleInitial IS NULL
    BEGIN
        RAISERROR('Employee Middle Initial must not be NULL.', 16, 1);
        RETURN; --Exit procedure
    END

    IF LEN(@EmployeeMiddleInitial) <> 1
    BEGIN
        RAISERROR('Employee Middle Initial must be exactly 1 character.', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Employee Gender
    IF @EmployeeGender NOT IN ('M', 'F') OR @EmployeeGender IS NULL
    BEGIN
        RAISERROR('Employee Gender must be specified as either ''M'' (Male) or ''F'' (Female).', 16, 1);
        RETURN; --Exit procedure
    END

    --Validate Employee Number format
    DECLARE @ExpectedEmployeeNumber NVARCHAR(7);
    SET @ExpectedEmployeeNumber = LEFT(@EmployeeLastName, 1) + RIGHT('000000' + @EmployeeNumber, 6);

    IF @EmployeeNumber <> @ExpectedEmployeeNumber
    BEGIN
        RAISERROR('Employee Number must start with the first letter of Employee Last Name followed by 6 digits.', 16, 1);
        RETURN; --Exit procedure
    END

    BEGIN TRY
        --Enforce Employee Number format
        SET @EmployeeNumber = LEFT(@EmployeeLastName, 1) + RIGHT('000000' + @EmployeeNumber, 6);

        UPDATE tblEmployee
        SET EmployeeLastName = @EmployeeLastName,
            EmployeeFirstName = @EmployeeFirstName,
            EmployeeMiddleInitial = @EmployeeMiddleInitial,
            EmployeeDateOfBirth = @EmployeeDateOfBirth,
            EmployeeNumber = @EmployeeNumber,
            EmployeeGender = @EmployeeGender,
            EmployeeSSN = @EmployeeSSN,
            EmployeeActiveFlag = @EmployeeActiveFlag,
            ModifyDate = GETDATE(),  -- Capture current date
            ModifiedBy = SYSTEM_USER  -- Capture current user
        WHERE EmployeeID = @EmployeeID;

        --Log successful update
        INSERT INTO tblLogErrors (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorUser
        ) VALUES (
            0,
            0,
            0,
            'usp_UpdateEmployee',
            0,
            'Employee updated successfully.',
            SYSTEM_USER
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNumber INT = ERROR_NUMBER(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE(),
                @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorUser NVARCHAR(128) = SYSTEM_USER;

        --Log error
        INSERT INTO tblLogErrors (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorUser
        ) VALUES (
            @ErrorNumber,
            @ErrorSeverity,
            @ErrorState,
            @ErrorProcedure,
            @ErrorLine,
            @ErrorMessage,
            @ErrorUser
        );

        --Raise custom error
        RAISERROR('Invalid middle initial, date of birth, gender, or missing first/last name.', 50000, 1);
    END CATCH;
END;
GO

/****************************************************************
Scenario 1
****************************************************************/
/****************************************************************
Author Name: Noah Mousseau
Create Date: 6/23/2024
Parameter 1: @EmployeeID
Parameter 2: @EmployeeLastName
Parameter 3: @EmployeeFirstName
Parameter 4: @EmployeeMiddleInitial
Parameter 5: @EmployeeDateOfBirth
Parameter 6: @EmployeeNumber
Parameter 7: @EmployeeGender
Parameter 8: @EmployeeSSN
Functionality: Retrieves an employee record from the database.
Assumptions: Assumes the EmployeeID is valid and exists.
****************************************************************/
--Do not create procedure if it already exists
IF OBJECT_ID('usp_GetEmployeeDetails', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_GetEmployeeDetails;
END
GO

CREATE PROCEDURE usp_GetEmployeeDetails
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeMiddleInitial,
        EmployeeDateOfBirth,
        EmployeeNumber,
        EmployeeGender,
        EmployeeSSN
    FROM tblEmployee
    WHERE EmployeeID = @EmployeeID;
END;
GO

--Indicate usage of HumanResources table
USE HumanResources;
GO

DECLARE @NewEmployeeID INT;

--Insert a new employee with valid data
BEGIN TRY
  EXEC usp_InsertEmployee 
    @EmployeeLastName = 'Doe',
    @EmployeeFirstName = 'John',
    @EmployeeMiddleInitial = 'A',
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = 'D123456',
    @EmployeeGender = 'M',
    @EmployeeSSN = '123456789';

  -- Call procedure to retrieve employee data, using EmployeeID = 1
  EXEC usp_GetEmployeeDetails @EmployeeID = 1;

END TRY
BEGIN CATCH
  --Error catch just in case
  PRINT 'Error occurred during employee insertion.';
END CATCH;

GO

/****************************************************************
Scenario 2
****************************************************************/
--EmployeeLastName violates NOT NULL constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = NULL,
    @EmployeeFirstName = 'Jane',
    @EmployeeMiddleInitial = 'B',
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = 'J123456',
    @EmployeeGender = 'F',
    @EmployeeSSN = '987654321';
GO

--EmployeeFirstName violates NOT NULL constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = 'Smith',
    @EmployeeFirstName = NULL,
    @EmployeeMiddleInitial = 'C',
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = 'S123456',
    @EmployeeGender = 'F',
    @EmployeeSSN = '123123123';
GO

--EmployeeMiddleInitial violates NOT NULL constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = 'White',
    @EmployeeFirstName = 'David',
    @EmployeeMiddleInitial = NULL,
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = 'W123456',
    @EmployeeGender = 'M',
    @EmployeeSSN = '321321321';
GO

--EmployeeDateOfBirth violates reasonable age constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = 'Black',
    @EmployeeFirstName = 'Olivia',
    @EmployeeMiddleInitial = 'E',
    @EmployeeDateOfBirth = '1880-01-01',
    @EmployeeNumber = 'B123456',
    @EmployeeGender = 'F',
    @EmployeeSSN = '456456456';
GO

--EmployeeNumber violates the format constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = 'Green',
    @EmployeeFirstName = 'James',
    @EmployeeMiddleInitial = 'F',
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = '123456G',
    @EmployeeGender = 'M',
    @EmployeeSSN = '789789789';
GO

--EmployeeGender violates possible values constraint
EXEC usp_InsertEmployee 
    @EmployeeLastName = 'Gray',
    @EmployeeFirstName = 'Emma',
    @EmployeeMiddleInitial = 'G',
    @EmployeeDateOfBirth = '1990-01-01',
    @EmployeeNumber = 'G123456',
    @EmployeeGender = 'X',
    @EmployeeSSN = '987987987';
GO

/****************************************************************
Scenario 3
****************************************************************/
--EmployeeFirstName violates NOT NULL constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = NULL, 
    @EmployeeMiddleInitial = 'A', 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeLastName violates NOT NULL constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = NULL, 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = 'A', 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeMiddleInitial violates NOT NULL constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = NULL, 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeMiddleInitial violates 1 character constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = 'AB', 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeDateOfBirth violates reasonable age constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = 'A', 
    @EmployeeDateOfBirth = '1800-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeGender violates possible values constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = 'A', 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'D123456', 
    @EmployeeGender = 'X', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;

--EmployeeNumber violates the format constraint
EXEC usp_UpdateEmployee 
    @EmployeeID = 1, 
    @EmployeeLastName = 'Doe', 
    @EmployeeFirstName = 'John', 
    @EmployeeMiddleInitial = 'A', 
    @EmployeeDateOfBirth = '1990-01-01', 
    @EmployeeNumber = 'W123456', 
    @EmployeeGender = 'M', 
    @EmployeeSSN = '123456789', 
    @EmployeeActiveFlag = 1;