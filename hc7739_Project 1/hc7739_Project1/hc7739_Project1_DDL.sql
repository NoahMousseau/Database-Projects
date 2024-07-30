/********************************************************************************
Author Name: Noah Mousseau
Access ID: hc7739
Assignment: 3
Date: 6/7/2024
Description: A file meant to perform various operations and test commands using the HumanResources table
********************************************************************************/

--Create HumanResources Database if it does not exist
IF DB_ID('HumanResources') IS NULL
BEGIN
    CREATE DATABASE HumanResources;
END
GO

--Ensure database is created before attempting to use it
USE HumanResources;
GO

--Create tblEmployee table if it does not exist
IF OBJECT_ID('tblEmployee', 'U') IS NULL
BEGIN
    CREATE TABLE tblEmployee (
        EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeLastName NVARCHAR(50) NOT NULL,
        EmployeeFirstName NVARCHAR(50) NOT NULL,
        EmployeeMiddleInitial CHAR(1) NULL DEFAULT '',
        EmployeeDateOfBirth DATE NOT NULL,
        EmployeeNumber CHAR(7) NOT NULL,
        EmployeeGender CHAR(1) NOT NULL CHECK (EmployeeGender IN ('M', 'F')),
        EmployeeSSN CHAR(9) NOT NULL,
        EmployeeActiveFlag BIT NOT NULL DEFAULT 1,
        CreateDate DATETIME NOT NULL DEFAULT GETDATE(),
        CreatedBy NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER,
        ModifyDate DATETIME NULL,
        ModifiedBy NVARCHAR(128) NULL
    );
END
GO

--Create tblLogErrors table if it does not exist
IF OBJECT_ID('tblLogErrors', 'U') IS NULL
BEGIN
    CREATE TABLE tblLogErrors (
        ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
        ErrorNumber INT,
        ErrorSeverity INT,
        ErrorState INT,
        ErrorProcedure NVARCHAR(128),
        ErrorLine INT,
        ErrorMessage NVARCHAR(4000),
        ErrorUser NVARCHAR(500)
    );
END
GO

--Drop existing trigger if it exists and create a new one
IF OBJECT_ID('trg_UpdateEmployee', 'TR') IS NOT NULL
BEGIN
    DROP TRIGGER trg_UpdateEmployee;
END
GO

CREATE TRIGGER trg_UpdateEmployee
ON tblEmployee
AFTER UPDATE
AS
BEGIN
    UPDATE tblEmployee
    SET ModifyDate = GETDATE(), ModifiedBy = SYSTEM_USER
    FROM tblEmployee E
    INNER JOIN inserted i ON E.EmployeeID = i.EmployeeID
    WHERE E.EmployeeID = i.EmployeeID;
END;
GO