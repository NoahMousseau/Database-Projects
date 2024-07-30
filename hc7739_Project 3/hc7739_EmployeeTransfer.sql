/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Creates the view
Assumptions: The Employees, Dependents, and Jobs tables exist in the database and have the required relevant columns
			 The foreign key relationships between Employees (self-join for managers), Dependents, and Jobs are correctly established and enforced
			 Data within these tables is consistent and adheres to the expected formats for all columns
****************************************************************/

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_EmployeeTransfer')
BEGIN
    DROP VIEW vw_EmployeeTransfer;
END
GO

CREATE VIEW vw_EmployeeTransfer AS
SELECT 
    e.employee_id,
    e.last_name AS EmployeeLastName,
    e.first_name AS EmployeeFirstName,
    e.email AS EmployeeEmail,
    e.phone_number AS EmployeePhoneNumber,
    j.job_title AS EmployeeJobTitle,
    e.hire_date AS EmployeeHireDate,
    m.last_name AS EmployeeManagerLastName,
    m.first_name AS EmployeeManagerFirstName,
    d.last_name AS DependentLastName,
    d.first_name AS DependentFirstName,
    d.relationship AS DependentRelationship,
    e.department_id,
    e.job_id
FROM 
    Employees e
    LEFT JOIN Employees m ON e.manager_id = m.employee_id
    LEFT JOIN Dependents d ON e.employee_id = d.employee_id
    LEFT JOIN Jobs j ON e.job_id = j.job_id;
GO

/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Creates the stored procedure to get a census of employee insurance
Assumptions: The view vw_EmployeeTransfer has been created successfully and includes the columns EmployeeID, EmployeeLastName, EmployeeFirstName, EmployeeEmail
			 The EmployeeID and EmployeePhoneNumber formats can be successfully transformed using FORMAT function calls
			 This current SQL Server environment allows the creation and manipulation of temporary tables
****************************************************************/
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_EmployeeInsuranceCensus')
BEGIN
    DROP PROCEDURE usp_EmployeeInsuranceCensus;
END
GO

CREATE PROCEDURE usp_EmployeeInsuranceCensus
AS
BEGIN
    -- Create a temporary table to store temp census information for display
    CREATE TABLE #TempEmployeeInsuranceCensus (
        EmployeeID NVARCHAR(6),
        EmployeeLastName NVARCHAR(50),
        EmployeeFirstName NVARCHAR(50),
        EmployeeEmail NVARCHAR(100),
        EmployeePhoneNumber NVARCHAR(12),
        DependentLastName NVARCHAR(50),
        DependentFirstName NVARCHAR(50),
        DependentRelationship NVARCHAR(50)
    );

    -- Insert data into temporary table
    INSERT INTO #TempEmployeeInsuranceCensus
    SELECT 
        RIGHT('000000' + e.employee_id, 6) AS EmployeeID,
        e.EmployeeLastName,
        e.EmployeeFirstName,
        e.EmployeeEmail,
        SUBSTRING(e.EmployeePhoneNumber, 1, 3) + '-' + SUBSTRING(e.EmployeePhoneNumber, 4, 3) + '-' + SUBSTRING(e.EmployeePhoneNumber, 7, 4) AS EmployeePhoneNumber,
        e.DependentLastName,
        e.DependentFirstName,
        e.DependentRelationship
    FROM 
        vw_EmployeeTransfer e;

    -- Remove the header row and just return the actual data
    SELECT 
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeEmail,
        EmployeePhoneNumber,
        DependentLastName,
        DependentFirstName,
        DependentRelationship
    FROM 
        #TempEmployeeInsuranceCensus
    ORDER BY 
        EmployeeLastName, 
        EmployeeFirstName, 
        DependentLastName, 
        DependentFirstName, 
        DependentRelationship;

    -- Add totals row
    SELECT 
        'TotalEmployees' AS EmployeeID,
        COUNT(DISTINCT EmployeeID) AS TotalUniqueEmployees
    FROM 
        #TempEmployeeInsuranceCensus;

    -- Drop the temporary table
    DROP TABLE #TempEmployeeInsuranceCensus;
END
GO



/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Creates the stored procedure to get employee details
Assumptions: The view vw_EmployeeTransfer has been created successfully and includes the columns EmployeeID, EmployeeLastName, EmployeeFirstName, EmployeeEmail, 
				EmployeePhoneNumber, EmployeeHireDate, EmployeeSalary, JobTitle, ManagerLastName, ManagerFirstName, department_id, job_id
			 The required tables exist already
			 The EmployeeID, EmployeePhoneNumber, EmployeeHireDate, and EmployeeSalary formats can be successfully transformed using FORMAT function calls
			 This current SQL Server environment allows the creation and manipulation of temporary tables
****************************************************************/
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_EmployeeDetails')
BEGIN
    DROP PROCEDURE usp_EmployeeDetails;
END
GO

CREATE PROCEDURE usp_EmployeeDetails
AS
BEGIN
    -- Create a temporary table to store EmployeeDetails information for display
    CREATE TABLE #TempEmployeeDetails (
        DepartmentRegionName NVARCHAR(50),
        DepartmentCountryName NVARCHAR(50),
        DepartmentName NVARCHAR(50),
        DepartmentLocation NVARCHAR(50),
        DepartmentStreetAddress NVARCHAR(100),
        DepartmentCity NVARCHAR(50),
        DepartmentState NVARCHAR(50),
        DepartmentZip NVARCHAR(10),
        DepartmentCountry NVARCHAR(50),
        EmployeeID NVARCHAR(6),
        EmployeeLastName NVARCHAR(50),
        EmployeeFirstName NVARCHAR(50),
        EmployeeEmail NVARCHAR(100),
        EmployeePhoneNumber NVARCHAR(12),
        EmployeeHireDate NVARCHAR(10),
        EmployeeSalary NVARCHAR(10),
        JobTitle NVARCHAR(50),
        ManagerLastName NVARCHAR(50),
        ManagerFirstName NVARCHAR(50)
    );

    -- Insert data into temporary table
    INSERT INTO #TempEmployeeDetails
    SELECT 
        r.region_name AS DepartmentRegionName,
        c.country_name AS DepartmentCountryName,
        d.department_name,
        d.location_id AS DepartmentLocation,
        l.street_address AS DepartmentStreetAddress,
        l.City AS DepartmentCity,
        l.state_province AS DepartmentState,
        l.postal_code AS DepartmentZip,
        c.country_name AS DepartmentCountry,
        RIGHT('000000' + e.employee_id, 6) AS EmployeeID,
        e.EmployeeLastName,
        e.EmployeeFirstName,
        e.EmployeeEmail,
        SUBSTRING(e.EmployeePhoneNumber, 1, 3) + '-' + SUBSTRING(e.EmployeePhoneNumber, 4, 3) + '-' + SUBSTRING(e.EmployeePhoneNumber, 7, 4) AS EmployeePhoneNumber,
        CONVERT(VARCHAR, e.EmployeeHireDate, 111) AS EmployeeHireDate,
        '$' + FORMAT(salary, 'N2') AS EmployeeSalary,
        j.job_title,
        m.last_name AS ManagerLastName,
        m.first_name AS ManagerFirstName
    FROM 
        vw_EmployeeTransfer e
        JOIN Departments d ON e.department_id = d.department_id
        JOIN Locations l ON d.location_id = l.location_id
        JOIN Countries c ON l.country_id = c.country_id
        JOIN Regions r ON c.region_id = r.region_id
        JOIN Jobs j ON e.job_id = j.job_id
        LEFT JOIN Employees m ON m.manager_id = m.employee_id;

    -- Remove the header row and return the actual data
    SELECT 
        DepartmentRegionName,
        DepartmentCountryName,
        DepartmentName,
        DepartmentLocation,
        DepartmentStreetAddress,
        DepartmentCity,
        DepartmentState,
        DepartmentZip,
        DepartmentCountry,
        EmployeeID,
        EmployeeLastName,
        EmployeeFirstName,
        EmployeeEmail,
        EmployeePhoneNumber,
        EmployeeHireDate,
        EmployeeSalary,
        JobTitle,
        ManagerLastName,
        ManagerFirstName
    FROM 
        #TempEmployeeDetails
    ORDER BY 
        DepartmentName, 
        ManagerLastName, 
        ManagerFirstName, 
        EmployeeLastName, 
        EmployeeFirstName;

    -- Drop the temporary table
    DROP TABLE #TempEmployeeDetails;
END
GO


-- Execution of stored procedures to demonstrate scenario(s) requirement fulfillment

-- Execute the Employee Insurance Census stored procedure
EXEC usp_EmployeeInsuranceCensus;

-- Execute the Employee Details stored procedure
EXEC usp_EmployeeDetails;

