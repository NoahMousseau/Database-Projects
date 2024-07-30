/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Instructions to create database statistics queries
Assumptions: The Employees, Jobs, Departments, Locations, Countries, Regions, and Dependents tables exist in the database and have the required relevant columns
			 Salary data is numeric and can be successfully formatted with currency symbols
			 Foreign key relationships between these tables are correctly established and enforced
			 Data within these tables is consistent, ensuring accurate counts and groupings
****************************************************************/


/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Finds the min_salary and max_salary by job title
Assumptions: The Employees table contains a Salary column that is numeric
			 The Jobs table includes a job_title column
			 There is a foreign key relationship between the Employees table and the Jobs table based on job_id
			 Salary data is formatted as currency, which is supported by the FORMAT function
			 The job_id field in the Employees table and the Jobs table is correctly populated and linked
****************************************************************/
SELECT 
    j.job_title AS JobTitle,
    FORMAT(MIN(e.Salary), '$#,##0.00') AS MinimumSalary,
    FORMAT(MAX(e.Salary), '$#,##0.00') AS MaximumSalary
FROM 
    Employees e
    JOIN Jobs j ON e.job_id = j.job_id
GROUP BY 
    j.job_title
ORDER BY 
    j.job_title;

/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Provides a count of employees for each department
Assumptions: The Employees table includes an employee_id and a department_id column
			 The Departments table includes a department_name column
			 There is a foreign key relationship between the Employees table and the Departments table based on department_id
			 Each department_id in the Employees table corresponds to an existing department_id in the Departments table
			 Employee data is accurately represented and counts are reliable
****************************************************************/
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS TotalEmployees
FROM 
    Employees e
    JOIN Departments d ON e.department_id = d.department_id
GROUP BY 
    d.department_name
ORDER BY 
    d.department_name;

/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Provides a list of managers and the number of employees they manage
Assumptions: 
****************************************************************/
SELECT 
    m.last_name AS ManagerLastName,
    m.first_name AS ManagerFirstName,
    COUNT(e.employee_id) AS TotalEmployees
FROM 
    Employees e
    JOIN Employees m ON e.manager_id = m.employee_id
GROUP BY 
    m.last_name, m.first_name
ORDER BY 
    ManagerLastName, ManagerFirstName;

/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Provides a list of locations and the number of departments in each
Assumptions: The Employees table includes employee_id, manager_id, first_name, and last_name columns
			 There is a self-referential foreign key relationship within the Employees table, where manager_id references employee_id
			 Every employee's manager_id is correctly associated with an existing employee_id in the Employees table
			 Managers and their direct reports are accurately represented in the data
****************************************************************/
SELECT 
    c.country_name AS Country,
    r.region_name AS Region,
    COUNT(d.department_id) AS TotalNumberDepartments
FROM 
    Departments d
    JOIN Locations l ON d.location_id = l.location_id
    JOIN Countries c ON l.country_id = c.country_id
    JOIN Regions r ON c.region_id = r.region_id
GROUP BY 
    c.country_name, r.region_name
ORDER BY 
    c.country_name, r.region_name;

/****************************************************************
Author Name: Noah Mousseau
Create Date: 7/25/2024
Functionality: Finds how many employees have no dependents
Assumptions: The Departments table includes a department_id and location_id column
			 The Locations table includes a location_id, country_id, and region_id columns
			 The Countries table includes country_id and region_id columns
			 The Regions table includes a region_id column
			 There are correct foreign key relationships linking these tables, ensuring that location, country, and region data are consistent
			 Data within these tables is complete and accurate for grouping and counting departments
****************************************************************/
SELECT 
    COUNT(e.employee_id) AS NumberOfEmployeesWithoutDependents
FROM 
    Employees e
    LEFT JOIN Dependents d ON e.employee_id = d.employee_id
WHERE 
    d.dependent_id IS NULL;
