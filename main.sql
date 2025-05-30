USE master
GO

IF DB_ID('Academy') IS NOT NULL
DROP DATABASE Academy
IF DB_ID ('Academy') IS NULL
CREATE DATABASE Academy

------

USE Academy
GO

CREATE TABLE Faculties (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL UNIQUE,

    CONSTRAINT CHK_Faculties_Name CHECK (Name <> '')
);

-- Create a table with departments
CREATE TABLE Departments (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Financing MONEY NOT NULL DEFAULT (0),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL,

    CONSTRAINT CHK_Departments_Financing CHECK (Financing >= 0),
    CONSTRAINT CHK_Departments_Name CHECK (Name <> ''),

    CONSTRAINT FK_Departments_Faculties FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

-- Create a table with groups
CREATE TABLE Groups (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL,
    Number INT NOT NULL DEFAULT (0),

    CONSTRAINT CHK_Departments_Number CHECK (Number >= 0 AND Number <= 50),
    CONSTRAINT CHK_Groups_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Groups_Year CHECK (Year BETWEEN 1 AND 5),

    CONSTRAINT FK_Groups_Departments FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

-- Create a table with subjects
CREATE TABLE Subjects (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL UNIQUE,

    CONSTRAINT CHK_Subjects_Name CHECK (Name <> '')
);

--Create table with Students
CREATE TABLE Students (
   ID INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL,
    Surname NVARCHAR(100) NOT NULL,
    GroupId INT NOT NULL,
    CONSTRAINT CHK_Students_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Students_Surname CHECK (Surname <> ''),
)
-- Create a table with teachers
CREATE TABLE Teachers (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Salary MONEY NOT NULL,
    Surname NVARCHAR(100) NOT NULL,

    CONSTRAINT CHK_Teachers_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Teachers_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Teachers_Surname CHECK (Surname <> '')
);

-- Create a table with lectures
CREATE TABLE Lectures (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    DayOfWeek INT NOT NULL,
    LectureRoom NVARCHAR(MAX) NOT NULL,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,

    CONSTRAINT CHK_Lectures_DayOfWeek CHECK (DayOfWeek BETWEEN 1 AND 7),
    CONSTRAINT CHK_Lectures_LectureRoom CHECK (LectureRoom <> ''),

    CONSTRAINT FK_Lectures_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    CONSTRAINT FK_Lectures_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

-- Create a table with lectures groups
CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY NOT NULL IDENTITY (1, 1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,

    CONSTRAINT FK_GroupsLectures_Groups FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    CONSTRAINT FK_GroupsLectures_Lectures FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

-- Execute the current batch of scripts
GO

-- Insert data into Faculties table
INSERT INTO Faculties (Name) VALUES
(N'Computer Science'),
(N'Mathematics'),
(N'Physics');

-- Insert data into Departments table
INSERT INTO Departments (Financing, Name, FacultyId) VALUES
(120000, N'Software Development', 1),
(110000, N'Software Engineering', 1),
(70000, N'Applied Math', 2),
(130000, N'Theoretical Physics', 3),
(90000, N'Artificial Intelligence', 1);

-- Insert data into Groups table
INSERT INTO Groups (Name, Year, DepartmentId) VALUES
(N'CS-101', 1, 1),
(N'CS-201', 2, 1),
(N'AI-101', 1, 5),
(N'MATH-101', 1, 3),
(N'PHYS-101', 1, 4);

-- Insert data into Subjects table
INSERT INTO Subjects (Name) VALUES
(N'Programming Basics'),
(N'Data Structures'),
(N'Algorithms'),
(N'AI Fundamentals'),
(N'Calculus'),
(N'Quantum Mechanics');

-- Insert data into Teachers table
INSERT INTO Teachers (Name, Salary, Surname) VALUES
(N'Dave McQueen', 3000, N'McQueen'),
(N'Jack Underhill', 3500, N'Underhill'),
(N'Anna Smith', 3200, N'Smith'),
(N'Linda Brown', 3100, N'Brown');

-- Insert data into Lectures table
INSERT INTO Lectures (DayOfWeek, LectureRoom, SubjectId, TeacherId) VALUES
(1, N'D201', 1, 1),
(2, N'D201', 2, 1),
(3, N'D202', 3, 2),
(4, N'D201', 4, 2),
(5, N'D203', 5, 3),
(1, N'D204', 6, 4),
(2, N'D201', 1, 2),
(3, N'D202', 2, 1),
(4, N'D203', 3, 3),
(5, N'D204', 4, 4);

-- Insert data into GroupsLectures table
INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(4, 6),
(5, 7),
(1, 8),
(2, 9),
(3, 10);

-- Execute the current batch of scripts
GO

-- Print the number of teachers of the department "Software Development".
SELECT COUNT(DISTINCT T.ID ) AS [Number of Teacher] FROM Teachers AS T
JOIN Lectures AS L ON L.TeacherId = T.Id
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
JOIN Groups AS Gr ON Gr.Id = GL.GroupId
JOIN Departments AS D ON D.Id = Gr.DepartmentId
WHERE D.Name = 'Software Development'
GO;

-- Print the number of lectures given by the teacher "Dave McQueen".
SELECT COUNT(DISTINCT L.Id) AS [Number of lectures] FROM Lectures AS L
JOIN Teachers AS T ON T.Id = L.TeacherId
WHERE T.Name = 'Dave McQueen'
GO;


-- Print the number of classes that are held in classroom "D201".
SELECT COUNT(GL.GroupId) AS [Number of classes] FROM Lectures AS L
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
WHERE L.LectureRoom = 'D201'
GO;

-- Print the names of the classrooms and the number of lectures held in them.
SELECT L.LectureRoom AS [Name of the classroom], COUNT(GL.LectureId) AS [Number of lectures] FROM Lectures AS L
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
GROUP BY L.LectureRoom
GO;

-- Print the number of students attending the lectures of teacher "Jack Underhill".
SELECT COUNT(DISTINCT S.Id) AS [Number of students] FROM Lectures AS L
JOIN Teachers AS T ON T.Id = L.TeacherId
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
JOIN Students AS S ON S.GroupId = GL.GroupId
WHERE T.Name = 'Jack Underhill'
GO;

-- Print the average salary of the faculty "Computer Science".
SELECT AVG(T.Salary) AS [Average salary] FROM Teachers AS T
JOIN Lectures AS L ON L.TeacherId = T.Id
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
JOIN Groups AS Gr ON Gr.Id = GL.GroupId
JOIN Departments AS D ON D.Id = Gr.DepartmentId
JOIN Faculties AS F ON F.Id = D.FacultyId
WHERE F.Name = 'Computer Science'
GO;

-- Print the minimum and maximum number of students among all groups.
SELECT MIN(Number) AS [Minimum students], MAX(Number) AS [Maximum students] FROM Groups AS G
SELECT G.Id, G.Name, COUNT(S.Id) AS StudentCount FROM Groups G
LEFT JOIN Students S ON G.Id = S.GroupId
GROUP BY G.Id, G.Name
GO

-- Print the average funding of the departments.
SELECT AVG(D.Financing) AS [Average funding of the departments] FROM Departments AS D
GO;

-- Print the full names of the teachers and the number of disciplines they teach.
SELECT T.Name + N' ' + T.Surname AS [Full name], COUNT(DISTINCT L.SubjectId) AS [Number of disciplines] FROM GroupsLectures AS GL
JOIN Lectures AS L ON L.Id = GL.LectureId
JOIN Teachers AS T ON T.Id = L.TeacherId
JOIN Subjects AS S ON S.Id = L.SubjectId
GROUP BY T.Name + N' ' + T.Surname
GO;

-- Print the number of lectures every day during the week.
SELECT L.DayOfWeek AS [Day of week], COUNT(L.Id) AS [Number of lectures] FROM Lectures AS L
GROUP BY L.DayOfWeek
GO;

-- Print the numbers of classrooms and the number of faculties whose lectures are given in them.
SELECT L.LectureRoom AS [Classroom], COUNT(DISTINCT F.Id) AS [Number of faculties] FROM Lectures AS L
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
JOIN Groups AS Gr ON Gr.Id = GL.GroupId
JOIN Departments AS D ON D.Id = Gr.DepartmentId
JOIN Faculties AS F ON F.Id = D.FacultyId
GROUP BY L.LectureRoom
GO;

-- Print the names of the faculties and the number of disciplines they teach.
SELECT F.Name AS [Faculty name], COUNT(DISTINCT S.Id) AS [Number of disciplines] FROM Lectures AS L
JOIN GroupsLectures AS GL ON GL.LectureId = L.Id
JOIN Groups AS Gr ON Gr.Id = GL.GroupId
JOIN Departments AS D ON D.Id = Gr.DepartmentId
JOIN Faculties AS F ON F.Id = D.FacultyId
JOIN Subjects AS S ON S.Id = L.SubjectId
GROUP BY F.Name
GO;

-- Print the number of lectures for each pair of lecturer-room.
SELECT T.Name AS [Lecturer], L.LectureRoom AS [Classroom], COUNT(L.Id) AS [Number of lectures] FROM Lectures AS L
JOIN Teachers AS T ON T.Id = L.TeacherId
GROUP BY T.Name, L.LectureRoom
GO;