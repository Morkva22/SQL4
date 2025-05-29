USE master
GO

IF DB_ID('Hospital') IS NOT NULL
DROP DATABASE Hospital
IF DB_ID ('Hospital') IS NULL
CREATE DATABASE Hospital

------

USE Hospital
GO

--create table for Examinations
CREATE TABLE Examinations (
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name nvarchar(100) NOT NULL UNIQUE,

    CONSTRAINT CHK_Examinations_Name CHECK (Name <> ''),
);

--Create table for DoctorsExaminations
CREATE TABLE DoctorsExaminations (
    ID INT PRIMARY KEY NOT NULL,
    EndTime TIME NOT NULL,
    StartTime TIME NOT NULL,
    DoctorID INT NOT NULL,
    ExaminationID INT NOT NULL,
    WardID INT NOT NULL,

    CONSTRAINT CHK_DoctorsExaminations_EndTime CHECK (EndTime > StartTime),
    CONSTRAINT CHK_DoctorsExaminations_StartTime CHECK (StartTime BETWEEN '08:00' AND '18:00'),

    CONSTRAINT FK_DoctorsExaminations_Doctors FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    CONSTRAINT FK_DoctorsExaminations_Examinations FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    CONSTRAINT FK_DoctorsExaminations_Wards FOREIGN KEY (WardId) REFERENCES Wards(Id)
);

--CREATE table for Doctors
CREATE TABLE Doctors (
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(max) NOT NULL,
    Surname NVARCHAR(max) NOT NULL,
    Premium MONEY NOT NULL DEFAULT (0),
    Salary MONEY NOT NULL,

    CONSTRAINT CHK_Doctor_Salary CHECK (Salary >= 0),
    CONSTRAINT CHK_Doctor_Premium CHECK (Premium >= 0),
    CONSTRAINT CHK_Doctor_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Doctor_Surname CHECK (Surname <> ''),

);

--create table for Wards
CREATE TABLE Wards (
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE,
    Places INT NOT NULL,
    DepartmentID INT NOT NULL,

    FOREIGN KEY (DepartmentID) REFERENCES Departments(ID),

    CONSTRAINT CHK_Ward_Places CHECK (Places >= 1),
    CONSTRAINT CHK_Ward_Name CHECK (Name <> ''),

);

--create table for Departments
CREATE TABLE Departments (
    ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,

    CONSTRAINT CHK_Department_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Department_Building CHECK (Building >= 0 AND Building <= 5)
);

-- Execute the current batch of scripts
GO;

-- Insert data into departments table
INSERT INTO Departments (Building, Name) VALUES
(1, N'Cardiology'),
(2, N'Neurology'),
(3, N'Oncology'),
(4, N'Pediatrics'),
(5, N'Surgery'),
(6, N'Gynecology'),
(7, N'Orthopedics'),
(8, N'ENT');

-- Insert data into wards table
INSERT INTO Wards (Name, Places, DepartmentId) VALUES
(N'Ward A', 12, 1),
(N'Ward B', 8, 1),
(N'Ward C', 15, 2),
(N'Ward D', 20, 2),
(N'Ward E', 5, 3),
(N'Ward F', 25, 3),
(N'Ward G', 30, 4),
(N'Ward H', 11, 4),
(N'Ward I', 9, 5),
(N'Ward J', 13, 5),
(N'Ward K', 60, 4),
(N'Ward L', 45, 4);

-- Insert data into doctors table
INSERT INTO Doctors (Name, Premium, Salary, Surname) VALUES
(N'Ivan', 500, 5000, N'Petrov'),
(N'Olga', 1000, 6000, N'Ivanova'),
(N'Sergei', 0, 4500, N'Sidorov'),
(N'Anna', 200, 4800, N'Kuznetsova'),
(N'Maria', 300, 5200, N'Popova'),
(N'Pavel', 700, 5500, N'Smirnov'),
(N'Elena', 400, 5100, N'Volkova'),
(N'Andrei', 600, 5300, N'Lebedev');

-- Insert data into examinations table
INSERT INTO Examinations (Name) VALUES
(N'ECG'),
(N'MRI'),
(N'CT Scan'),
(N'Ultrasound'),
(N'X-Ray');

-- Insert data into doctors examinations table
INSERT INTO DoctorsExaminations (EndTime, StartTime, DoctorId, ExaminationId, WardId) VALUES
('09:00', '08:00', 1, 1, 1),
('10:00', '09:00', 2, 1, 1),
('11:00', '10:00', 3, 2, 3),
('12:00', '11:00', 4, 2, 4),
('13:00', '12:00', 5, 3, 6),
('14:00', '13:00', 6, 3, 6),
('15:00', '14:00', 7, 4, 7),
('16:00', '15:00', 8, 4, 7),
('17:00', '16:00', 1, 5, 10),
('18:00', '17:00', 2, 5, 10),
('09:30', '08:30', 3, 1, 2),
('10:30', '09:30', 4, 1, 2),
('11:30', '10:30', 5, 1, 2),
('12:30', '11:30', 6, 1, 2),
('13:30', '12:30', 7, 1, 2);

-- Execute the current batch of scripts
GO;

-- Print the number of wards with capacity greater than 10.
SELECT COUNT (W.Places) AS [Number of wards] FROM Wards AS W
WHERE W.Places > 10;
GO

-- Print the names of the buildings and the number of wards in each of them.
SELECT D.Building AS [Building], COUNT (W.ID) AS [Number of wards] FROM Wards AS W
JOIN Departments AS D ON W.DepartmentID = D.ID
GROUP BY D.Building
GO

-- Print the names of the departments and the number of wards in each of them.
SELECT D.Name AS [Department], COUNT (W.ID) AS [Number of Wards] FROM Wards AS W
JOIN Departments AS D ON W.DepartmentID = D.ID
GROUP BY D.Name
GO

-- Print the names of the departments and the total allowance of doctors in each of them.
SELECT De.Name AS [Department], SUM(D.Premium) AS [Total Premium] FROM Doctors AS D
JOIN DoctorsExaminations AS DExam ON DExam.DoctorId = D.Id
JOIN Wards AS W ON W.ID = DExam.WardID
JOIN Departments AS De ON De.Id = W.DepartmentId
GROUP BY De.Name
GO

-- Print the names of the departments in which 5 or more doctors perform the examination.
SELECT Dep.Name AS [Department] FROM Doctors AS D
JOIN DoctorsExaminations AS DExam ON DExam.ID = D.ID
JOIN Wards AS W ON W.Id = DExam.WardID
JOIN Departments AS Dep ON Dep.Id = W.DepartmentID
GROUP BY Dep.Name
HAVING COUNT(DISTINCT DExam.DoctorID) >= 5
GO

-- Print the number of doctors and their total salary (sum of rate and allowance).
SELECT COUNT(D.ID) AS [Number Of Doctors], SUM(D.Salary +D.Premium) AS [Total Salary] FROM Doctors AS D
GO

-- Print the average salary (sum of salary and allowance) of doctors.
SELECT AVG(D.Salary + D.Premium) AS [Avarage Salary] FROM Doctors AS D
GO

-- Print the names of the wards with the minimum capacity.
SELECT W.Name AS [Wards Name], W.Places FROM Wards AS W
GROUP BY W.Name, W.Places
HAVING W.Places = MIN(Places)
GO

-- Print in which of the buildings 1, 6, 7 and 8, the total number of beds in the wards exceeds 100. Only wards with more than 10 beds should be considered.
SELECT D.Building AS [Building], SUM(W.Places) AS [Total Places] FROM Wards AS W
JOIN Departments AS D ON W.DepartmentID = D.ID
WHERE W.Places > 10 AND D.Building IN (1,6,7,8)
GROUP BY D.Building
HAVING SUM(W.Places) > 100
GO

