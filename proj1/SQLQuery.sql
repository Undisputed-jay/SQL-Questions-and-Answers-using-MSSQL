SELECT * FROM HR;

-- 1. Total Employee: The sum of Total Employee from HR Dashboard
SELECT 
	SUM(Employee_Count) AS Total_Employee
FROM dbo.HR;

--2. Total Attrition: The sum of Total Attrition from HR Dashboard

ALTER TABLE HR
ALTER COLUMN Attrition INT NOT NULL;

SELECT 
	CAST(SUM(Attrition) AS INT) AS Total_Attrition
FROM dbo.HR;

--3. Attrition Rate: 
SELECT
	(SUM(Employee_Count) / SUM(Attrition)) AS Attrition_Rate
FROM dbo.HR;

--4. Active Employee: 
SELECT
	(SUM(Employee_Count) - SUM(Attrition)) AS Active_Employee
FROM dbo.HR;

--5. Average Age
SELECT
	AVG(Age) AS Average_Age
FROM dbo.HR;

--6. Attrition Count by Department
SELECT 
	Department, SUM(Attrition) AS Attrition_by_Department
FROM 
	dbo.HR
GROUP BY Department
ORDER BY Attrition_by_Department; 

--7. Job Role By Rate of Total EMployee
SELECT
	Job_Role, SUM(Employee_count) AS Total_Employee
FROM
	dbo.HR
GROUP BY Job_Role
ORDER BY Total_Employee DESC;

--8. Total Employee by Education
SELECT
	Education_Field, SUM(Employee_count) AS Total_Employee
FROM
	dbo.HR
GROUP BY Education_Field
ORDER BY Total_Employee DESC;

--9. Total Employee by Age Group
SELECT
	CF_age_band, SUM(Employee_count) AS Total_Employee
FROM 
	dbo.HR
GROUP BY CF_age_band
ORDER BY Total_Employee DESC;

--10. Job Role by Month by Gender
SELECT
	Job_Role, Gender, SUM(Monthly_Income) AS Monthly_Income
FROM dbo.HR
GROUP BY Job_Role, Gender
ORDER BY Monthly_Income;
