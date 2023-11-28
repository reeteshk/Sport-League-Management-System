-- USING MASTER DATABASE FOR CREATION OF THE DATABASE
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
-- ######### CREATING A USER TABLE #########
CREATE TABLE [user] (
  userId INT PRIMARY KEY IDENTITY(1000,1),
  userEmail NVARCHAR(255) NOT NULL,
  firstName NVARCHAR(100),
  lastName NVARCHAR(100),
  [password] VARBINARY(400) NOT NULL,
  streetName NVARCHAR(255),
  [state] NVARCHAR(100),
  country NVARCHAR(100),
  postalCode VARCHAR(10),
  userType NVARCHAR(50)
  CHECK (userType IN ('Viewer', 'TeamStaff', 'Admin')),
  CONSTRAINT CHK_PostalCode CHECK (ISNUMERIC(postalCode) = 1 AND LEN(postalCode) = 5)
)

GO

-- ######### CREATING A TEAM TABLE #########
CREATE TABLE [team] (
  teamId INT PRIMARY KEY,
  teamName NVARCHAR(100),
  teamLocation NVARCHAR(100),
  sponsorship NVARCHAR(100)
)

GO

-- ######### CREATING A SKILL TABLE #########
CREATE TABLE [skills] (
  skillId INT PRIMARY KEY,
  skillName NVARCHAR(100),
  skillDescription NVARCHAR(255)
)

GO

-- ######### CREATING A ADMIN TABLE #########
CREATE TABLE [admin] (
  adminId INT PRIMARY KEY,
  adminRole NVARCHAR(100),
  adminPermissions NVARCHAR(100),
  joiningDate DATE,
  yearsOfExperience INT,
  lastLogin DATETIME
)

ALTER TABLE [admin] ADD CONSTRAINT chkYearsOfExperience CHECK (yearsOfExperience >= 0)

GO

-- ######### CREATING A STADIUM TABLE #########
CREATE TABLE [stadium] (
  stadiumId INT PRIMARY KEY,
  stadiumName NVARCHAR(100),
  [location] NVARCHAR(100),
  capacity INT,
  adminId INT,
  FOREIGN KEY (adminId) REFERENCES Admin(adminId)
)

GO

-- ######### CREATING A VIEWER TABLE #########
CREATE TABLE [viewer] (
  viewerId INT PRIMARY KEY,
  favoriteTeam NVARCHAR(100),
  languagePreference NVARCHAR(50),
  FOREIGN KEY (viewerId) REFERENCES [user](userId)
)

GO

-- ######### CREATING A TEAM STAFF TABLE #########
CREATE TABLE [teamStaff] (
  teamStaffId INT PRIMARY KEY,
  playingCountry NVARCHAR(100),
  staffType NVARCHAR(50) not NULL,
  Check (staffType IN ('Coach', 'Player')),
  FOREIGN KEY (teamStaffId) REFERENCES [user](userId)
)

GO

-- ######### CREATING A COACH TABLE #########
CREATE TABLE [coach] (
  coachId INT PRIMARY KEY,
  coachingExperience INT,
  specialization NVARCHAR(100),
  coachingPhilosophy NVARCHAR(255),
  FOREIGN KEY (coachId) REFERENCES [user](userId)
)

GO

-- ######### CREATING A PLAYER TABLE #########
CREATE TABLE [player] (
  playerId INT PRIMARY KEY,
  position NVARCHAR(50),
  isSubstitute BIT,
  minutesPlayed INT,
  FOREIGN KEY (playerId) REFERENCES [user](userId)
)

GO

-- ######### CREATING A MATCH TABLE #########
CREATE TABLE [match] (
  matchId INT PRIMARY KEY,
  matchDate DATETIME,
  homeTeamId INT,
  AwayTeamId INT,
  stadiumId INT,
  winningTeam INT,
  FOREIGN KEY (homeTeamId) REFERENCES [team](teamId),
  FOREIGN KEY (awayTeamId) REFERENCES [team](teamId),
  FOREIGN KEY (stadiumId) REFERENCES [stadium](stadiumId)
)

GO

-- ######### CREATING A PLAYER STATISTICS TABLE #########
CREATE TABLE [playerStatistics] (
  playerStatsId INT PRIMARY KEY,
  matchPlayerId INT,
  playerId INT,
  score INT,
  FOREIGN KEY (playerId) REFERENCES [player](playerId),
  FOREIGN KEY (matchPlayerId) REFERENCES [match](matchId)
)

GO

-- ######### CREATING A PLAYER SKILLS TABLE #########
CREATE TABLE [playerSkills] (
  playerId INT,
  skillId INT,
  PRIMARY KEY (playerId, skillId),
  FOREIGN KEY (playerId) REFERENCES [player](playerId),
  FOREIGN KEY (skillId) REFERENCES [skills](skillId)
)

GO

-- ######### CREATING A CONTRACT TABLE #########
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

-- ######### CREATING A TRANSACTION TABLE #########
CREATE TABLE [transaction] (
  transactionId INT PRIMARY KEY IDENTITY (5000,1),
  matchId INT,
  viewerId INT,
  amount MONEY,
  paymentMode NVARCHAR(50),
  transactionTime DATETIME,
  FOREIGN KEY (matchId) REFERENCES [match](matchId),
  FOREIGN KEY (viewerId) REFERENCES [viewer](viewerId)
)
ALTER TABLE [transaction] ADD CONSTRAINT CHK_PositiveAmount CHECK (amount >= 0)
ALTER TABLE [transaction] ADD CONSTRAINT CHK_TransactionTime CHECK (transactionTime <= GETDATE())