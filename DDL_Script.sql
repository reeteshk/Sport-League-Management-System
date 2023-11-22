-- EXEC sp_who2
-- --Run kill spid for each process that is using the database to be dropped.
-- kill <<processid>> -- Kill 57
-- SELECT request_session_id
-- FROM sys.dm_tran_locks
-- WHERE resource_database_id = DB_ID('G_MAIN_DE')
-- SELECT name FROM sys.databases;

USE master

-- IF DATABASE EXISTS, DROP
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'sportsleaguemgmtsys')
    DROP DATABASE sportsleaguemgmtsys
GO

CREATE DATABASE sportsleaguemgmtsys;

GO

USE sportsleaguemgmtsys

GO

-- Creating tables

-- User table
-- Need to make changes//need to check
CREATE TABLE [user] (
  userId INT PRIMARY KEY IDENTITY(1000,1),
  userEmail NVARCHAR(255) NOT NULL,
  firstName NVARCHAR(100),
  lastName NVARCHAR(100),
  [password] VARBINARY(400) NOT NULL,
  streetName NVARCHAR(255),
  [state] NVARCHAR(100),
  country NVARCHAR(100),
  postalCode NVARCHAR(20),
  userType NVARCHAR(50)
  Check (userType IN ('Viewer', 'TeamStaff', 'Admin')) --added the check contraint for viewer,teamstaff, admin
)

GO

-- Team table
CREATE TABLE [team] (
  teamId INT PRIMARY KEY,
  teamName NVARCHAR(100),
  teamLocation NVARCHAR(100),
  sponsorship NVARCHAR(100)
)

GO

-- Skills table
CREATE TABLE [skills] (
  skillId INT PRIMARY KEY,
  skillName NVARCHAR(100),
  skillDescription NVARCHAR(255)
)

GO

-- Admin table // we will write UDF function to get yearsofexperience from joining date
CREATE TABLE [admin] (
  adminId INT PRIMARY KEY,
  adminRole NVARCHAR(100),
  adminPermissions NVARCHAR(100),
  joiningDate DATE,
  yearsOfExperience INT,
  lastLogin DATETIME
)

GO

-- Stadium table
CREATE TABLE [stadium] (
  stadiumId INT PRIMARY KEY,
  stadiumName NVARCHAR(100),
  [location] NVARCHAR(100),
  capacity INT,
  adminId INT,
  FOREIGN KEY (adminId) REFERENCES Admin(adminId)
)

GO

-- Viewer table
CREATE TABLE [viewer] (
  viewerId INT PRIMARY KEY,
  favoriteTeam NVARCHAR(100),
  languagePreference NVARCHAR(50),
  FOREIGN KEY (viewerId) REFERENCES [user](userId)
)

GO

-- Team Staff table,//Need to check
CREATE TABLE [teamStaff] (
  teamStaffId INT PRIMARY KEY,
  playingCountry NVARCHAR(100),
  staffType NVARCHAR(50) not NULL,
  Check (staffType IN ('Coach', 'Player')),
  FOREIGN KEY (teamStaffId) REFERENCES [user](userId)
)

GO
--Incomplete
-- Coach table //Need to check Staff should be used here
CREATE TABLE [coach] (
  coachId INT PRIMARY KEY,
  coachingExperience INT,
  specialization NVARCHAR(100),
  coachingPhilosophy NVARCHAR(255),
  FOREIGN KEY (coachId) REFERENCES [user](userId)
)

GO
--Incomplete
-- Player table //Need to check Staff should be used here
CREATE TABLE [player] (
  playerId INT PRIMARY KEY,
  position NVARCHAR(50),
  isSubstitute BIT,
  minutesPlayed INT,
  FOREIGN KEY (playerId) REFERENCES [user](userId)
)

GO

--Done
-- Match table
CREATE TABLE [match] (
  matchId INT PRIMARY KEY,
  matchDate DATETIME,
  matchLocation NVARCHAR(100),
  homeTeamId INT,
  AwayTeamId INT,
  stadiumId INT,
  winningTeam INT,
  FOREIGN KEY (homeTeamId) REFERENCES [team](teamId),
  FOREIGN KEY (awayTeamId) REFERENCES [team](teamId),
  FOREIGN KEY (stadiumId) REFERENCES [stadium](stadiumId)
)

GO
--Done
-- Player Statistics table
CREATE TABLE [playerStatistics] (
  playerStatsId INT PRIMARY KEY,
  matchPlayerId INT,
  playerId INT,
  score INT,
  FOREIGN KEY (playerId) REFERENCES [player](playerId),
  FOREIGN KEY (matchPlayerId) REFERENCES [match](matchId)
)

GO
--Done
-- Player Skills table
CREATE TABLE [playerSkills] (
  playerId INT,
  skillId INT,
  PRIMARY KEY (playerId, skillId),
  FOREIGN KEY (playerId) REFERENCES [player](playerId),
  FOREIGN KEY (skillId) REFERENCES [skills](skillId)
)

GO

--Done
-- Contract table
CREATE TABLE [contract] (
  contractId INT PRIMARY KEY IDENTITY(3000, 1),
  [description] NVARCHAR(255),
  startDate DATETIME,
  endDate DATETIME,
  teamId INT,
  teamStaffId INT,
  isTeamCaptain BIT,
  FOREIGN KEY (teamId) REFERENCES [team](teamId),
  FOREIGN KEY (teamStaffId) REFERENCES [teamStaff](teamStaffId)
)

GO
--Done
-- Transaction table
CREATE TABLE [transaction] (
  transactionId INT PRIMARY KEY,
  matchId INT,
  viewerId INT,
  amount MONEY,
  paymentMode NVARCHAR(50),
  transactionTime DATETIME,
  FOREIGN KEY (matchId) REFERENCES [match](matchId),
  FOREIGN KEY (viewerId) REFERENCES [viewer](viewerId)
)

-- 6. Column data encrpytion
-- 
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Dmdd@sportsleague';

--Verifying master key
SELECT name KeyName,
symmetric_key_id KeyID,
key_length KeyLength,
algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

GO

CREATE CERTIFICATE userPass
WITH SUBJECT = 'User Sample Password';

GO

CREATE SYMMETRIC KEY userPass_SM
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE userPass;

GO

OPEN SYMMETRIC KEY userPass_SM
DECRYPTION BY CERTIFICATE userPass;

--function to encrypt password --not working so not used in insert command yet
GO

ALTER FUNCTION encryptPassword (@password varchar(50)) 
RETURNS varbinary 
AS 
BEGIN
    DECLARE @encryptedpassword varbinary
    SELECT @encryptedpassword = EncryptByKey(Key_GUID('userPass_SM'), convert(varbinary,@password) )
    RETURN @encryptedpassword
END

GO

INSERT INTO [user] (userEmail, firstName, lastName, [password], streetName, [state], country, postalCode, userType)
VALUES
  ('john.doe@example.com', 'John', 'Doe', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '123 Main St', 'CA', 'USA', '12345', 'TeamStaff'),
  ('jane.smith@example.com', 'Jane', 'Smith', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '456 Oak St', 'NY', 'USA', '67890', 'TeamStaff'),
  ('bob.viewer@example.com', 'Bob', 'Viewer', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '789 Pine St', 'TX', 'USA', '56789', 'Viewer'),
  ('alice.teamstaff@example.com', 'Alice', 'TeamStaff', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '321 Elm St', 'FL', 'USA', '23456', 'TeamStaff'),
  ('sam.viewer@example.com', 'Sam', 'Viewer', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '654 Cedar St', 'AZ', 'USA', '98765', 'Viewer'),
  ('lisa.teamstaff@example.com', 'Lisa', 'TeamStaff', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '987 Maple St', 'WA', 'USA', '54321', 'TeamStaff'),
  ('mike.teamstaff@example.com', 'Mike', 'TeamStaff', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '135 Birch St', 'GA', 'USA', '34567', 'TeamStaff'),
  ('sara.viewer@example.com', 'Sara', 'Viewer', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '246 Walnut St', 'NC', 'USA', '87654', 'Viewer'),
  ('david.teamstaff@example.com', 'David', 'TeamStaff', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '789 Pine St', 'CO', 'USA', '23456', 'TeamStaff'),
  ('emily.viewer@example.com', 'Emily', 'Viewer', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '012 Redwood St', 'OR', 'USA', '65432', 'Viewer'),
  ('shreyangi@gmail.com', 'Shreyangi', 'Prasad', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '60 Glen road', 'MA', 'USA', '02445', 'Admin'),
  ('manjari@gmail.com', 'Manjari', 'Chaturvedi', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Street2', 'MA', 'USA', 'Postal2', 'Admin'),
  ('monisha@gmail.com', 'Monisha', 'Pulavarthy', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Street2', 'MA', 'USA', 'Postal2', 'Admin'),
  ('khushbu@gmail.com', 'Khushbu', 'Singh', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Street2', 'MA', 'USA', 'Postal2', 'Admin'),
  ('reetesh@gmail.com', 'Reetesh', 'Kesarwani', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Street2', 'MA', 'USA', 'Postal2', 'Admin');

GO

SELECT * FROM [user]

GO

CREATE FUNCTION dbo.CalculateYearsOfExperience (@JoiningDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @CurrentDate DATE = GETDATE();

    RETURN DATEDIFF(YEAR, @JoiningDate, @CurrentDate);
END

GO

INSERT INTO [admin] (adminId,adminRole,adminPermissions,joiningDate,yearsOfExperience,lastLogin) 
VALUES (1010,'Head Admin','Master','2019-05-20', dbo.CalculateYearsOfExperience('2019-05-20'),GETDATE()),
        (1011,'Head Admin','Master','2021-01-15', dbo.CalculateYearsOfExperience('2021-01-15'),GETDATE()),
        (1012,'Head Admin','Master','2020-08-07', dbo.CalculateYearsOfExperience('2020-08-07'),GETDATE()),
        (1013,'Head Admin','Master','2018-12-01', dbo.CalculateYearsOfExperience('2018-12-01'),GETDATE()),
        (1014,'Head Admin','Master','2017-03-10', dbo.CalculateYearsOfExperience('2017-03-10'),GETDATE());

GO

SELECT * FROM [admin] a JOIN [user] u ON a.adminId=u.userId

GO

CREATE PROC insertToAdminTable @adminRole NVARCHAR(100), @adminPermissions NVARCHAR(100), @joiningDate DATE AS 
BEGIN
    DECLARE @message VARCHAR(100)
    IF EXISTS (SELECT userId FROM [user] WHERE userType = 'Admin' AND NOT EXISTS (SELECT 1 FROM [admin] WHERE adminId = userId))
    BEGIN
        DECLARE @yearsOfExperience INT
        SELECT @yearsOfExperience=dbo.CalculateYearsOfExperience(@joiningDate)
        INSERT INTO [admin] (adminId,adminRole,adminPermissions,joiningDate,yearsOfExperience,lastLogin)  
        SELECT userId, @adminRole AS adminRole, @adminPermissions AS adminPermissions, @joiningDate AS joiningDate, 
        @yearsOfExperience AS yearsOfExperience , GETDATE() AS lastLogin  
        FROM [user] WHERE userType = 'Admin' AND NOT EXISTS (SELECT 1 FROM [admin] WHERE adminId = userId)
    END
END

GO

EXEC insertToAdminTable @adminRole='Head Admin', @adminPermissions='Master', @joiningDate='2019-01-15'

GO

INSERT INTO [teamStaff] (teamStaffId,playingCountry,staffType) 
VALUES (1000,'USA','Coach'),
        (1001,'USA','Player'),
        (1003,'USA','Player'),
        (1005,'USA','Player'),
        (1006,'USA','Player'),
        (1008,'UK','Player');

SELECT * FROM [teamStaff] t JOIN [user] u ON t.teamStaffId=u.userId

GO

CREATE PROC insertToTeamStaffTable @playingCountry NVARCHAR(100), @staffType NVARCHAR(50) AS 
BEGIN
    DECLARE @message VARCHAR(100)
    IF EXISTS (SELECT userId FROM [user] WHERE userType = 'TeamStaff' AND NOT EXISTS (SELECT 1 FROM [teamStaff] WHERE teamStaffId = userId))
    BEGIN
        INSERT INTO [teamStaff] (teamStaffId,playingCountry,staffType)  
        SELECT userId, @playingCountry AS playingCountry, @staffType AS staffType 
        FROM [user] WHERE userType = 'TeamStaff' AND NOT EXISTS (SELECT 1 FROM [teamStaff] WHERE teamStaffId = userId)
    END
END

INSERT INTO [viewer] (viewerId,favoriteTeam,languagePreference) 
VALUES (1002,'RedSox','English'), 
        (1004,'RedSox','English'), 
        (1007,'RedSox','Spanish'), 
        (1009,'Yankees','English');

SELECT * FROM [viewer] v JOIN [user] u ON v.viewerId=u.userId

INSERT INTO [player] (playerId,[position],isSubstitute,minutesPlayed) 
VALUES (1001, 'Pitcher', 0, 102), 
        (1003, 'Catcher', 0, 109), 
        (1005, 'Outfielder', 1, 0), 
        (1006, 'Infielder', 0, 64), 
        (1008, 'Pitcher', 0, 120);

SELECT * FROM [player] p JOIN [user] u ON p.playerId=u.userId JOIN [teamStaff] t ON t.teamStaffId=p.playerId

INSERT INTO [coach] (coachId, coachingExperience, specialization, coachingPhilosophy) 
VALUES (1000, 5, 'Pitching and bullpen', 'Strong leadership skills')

SELECT * FROM [coach] c JOIN [user] u ON c.coachId=u.userId JOIN [teamStaff] t ON t.teamStaffId=c.coachId

INSERT INTO [skills] (skillId, skillName, skillDescription)
VALUES
  (1, 'Batting', 'Ability to hit the baseball with the bat'),
  (2, 'Pitching', 'Skill of throwing the baseball to the batter'),
  (3, 'Fielding', 'Ability to catch and play the ball in the field'),
  (4, 'Base Running', 'Skill of running bases efficiently'),
  (5, 'Catching', 'Skill of catching pitched balls as a catcher'),
  (6, 'Throwing Accuracy', 'Ability to throw the ball accurately to a target'),
  (7, 'Team Coordination', 'Working effectively with teammates on the field'),
  (8, 'Game Strategy', 'Understanding and implementing strategic plays'),
  (9, 'Physical Fitness', 'Maintaining good physical condition for peak performance'),
  (10, 'Sportsmanship', 'Displaying fair play and respect for opponents');

SELECT * FROM [skills]

SELECT * FROM playerSkills

INSERT INTO [playerSkills] (playerId, skillId)
VALUES
  (1001, 1), (1001, 2), (1001, 6), (1001, 8),
  (1003, 2), (1003, 5), (1003, 7),
  (1005, 3), (1005, 6), (1005, 7), (1005, 9),
  (1006, 3), (1006, 4), (1006, 7),
  (1008, 1), (1008, 2), (1008, 6), (1008, 8);

SELECT * FROM player p JOIN playerSkills p_s ON p.playerId=p_s.playerId JOIN skills s ON p_s.skillId=s.skillId

INSERT INTO [team] (teamId, teamName, teamLocation, sponsorship) 
VALUES (1, 'RedSoX', 'Boston', 'MassMutual'), 
        (2, 'Yankees', 'New York', 'Starr insurance')

-- Insert values into the contract table for players
INSERT INTO [contract] ([description], startDate, endDate, teamId, teamStaffId, isTeamCaptain)
VALUES
  ('Player Contract for Jane Smith', '2023-01-01', '2023-12-31', 1, 1001, 1),
  ('Player Contract for Alice TeamStaff', '2023-01-01', '2023-12-31', 1, 1003, 0),
  ('Player Contract for Lisa TeamStaff', '2023-01-01', '2023-12-31', 2, 1005, 0),
  ('Player Contract for Mike TeamStaff', '2023-01-01', '2023-12-31', 2, 1006, 0),
  ('Player Contract for David TeamStaff', '2023-01-01', '2023-12-31', 1, 1008, 0);

-- Insert values into the contract table for coaches
INSERT INTO [contract] ([description], startDate, endDate, teamId, teamStaffId, isTeamCaptain)
VALUES
  ('Coach Contract for John Doe', '2023-01-01', '2023-12-31', 1, 1000, 0);

SELECT * FROM [contract]
