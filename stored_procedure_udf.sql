GO

USE sportsleaguemgmtsys

OPEN SYMMETRIC KEY userPass_SM
DECRYPTION BY CERTIFICATE userPass;

GO
-- ######### STORED PROCEDURES #########

-- 1. Stored procedure to get details of a given player, from user table, player table, skills table and team table
CREATE OR ALTER PROCEDURE GetPlayerDetails @playerId INT
AS
BEGIN
    -- Get player details
    SELECT
        u.firstName + ' ' + u.lastName AS playerName, p.position, p.isSubstitute, p.minutesPlayed,
        -- Get player skills using EXISTS
        (SELECT s.skillName FROM skills s WHERE EXISTS (
            SELECT 1 FROM playerSkills ps WHERE ps.playerId = @playerId AND ps.skillId = s.skillId )
         FOR JSON PATH ) AS playerSkills,
        -- Get team details
        t.teamName, t.teamLocation, t.sponsorship 
    FROM player p
    JOIN [user] u ON p.playerId = u.userId
    LEFT JOIN contract c ON u.userId = c.teamStaffId 
    LEFT JOIN team t ON c.teamId = t.teamId
    WHERE p.playerId = @playerId
END

GO

--Executing the procedure
EXEC GetPlayerDetails @playerId=1007

GO

-- 2. Stored procedure to update user details given a new address and display a success message
CREATE OR ALTER PROCEDURE UpdateUserDetails @userId INT, @streetName NVARCHAR(255), @state NVARCHAR(100), @country NVARCHAR(100), @postalCode NVARCHAR(10) 
AS
BEGIN
    -- Update user details in the [user] table
    UPDATE [user] SET
        streetName = @streetName,
        [state] = @state,
        country = @country,
        postalCode = @postalCode 
    WHERE
        userId = @userId;
    -- Display a success message
    PRINT 'User details updated successfully.';
END

GO

-- Execute the stored procedure with the specified parameters
EXEC UpdateUserDetails @userId = 1007, @streetName='12 turnberry', @state='NJ', @country='USA', @postalCode='07726' 
SELECT * FROM [user] WHERE [userId]=1007
GO

-- 3. Adding a user to admin table when added to user table with additional input for admin parameters

GO

CREATE OR ALTER PROC insertToAdminTable @adminRole NVARCHAR(100), @adminPermissions NVARCHAR(100), @joiningDate DATE AS 
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

INSERT INTO [user] (userEmail, firstName, lastName, [password], streetName, [state], country, postalCode, userType)
VALUES
    ('shreyangi_prasad@gmail.com', 'Shreyangi', 'Prasad', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player1 Street', 'CA', 'USA', '11111', 'Admin');

SELECT * FROM [admin] a JOIN [user] u ON u.userId = a.adminId WHERE u.userEmail='shreyangi_prasad@gmail.com' -- No should be found record

EXEC insertToAdminTable @adminRole='Head Admin', @adminPermissions='Master', @joiningDate='2019-01-15' -- Executing stored procedure will insert the user to admin table with additional details

SELECT * FROM [admin] a JOIN [user] u ON u.userId = a.adminId WHERE u.userEmail='shreyangi_prasad@gmail.com' -- Record should be found

GO

-- ######### VIEWS #########
-- 1. Creating view for a player performance
CREATE OR ALTER VIEW PlayerPerformance AS 
    SELECT p.playerId, u.firstName + ' ' + u.lastName AS playerName, 
            SUM(ps.score) AS totalScore, AVG(ps.score) AS averageScore, 
            SUM(p.minutesPlayed) AS totalMinutesPlayed, 
            COUNT(DISTINCT m.matchId) AS matchesPlayed 
    FROM [player] p 
    JOIN [playerStatistics] ps ON p.playerId = ps.playerId
    JOIN [match] m ON ps.matchPlayerId = m.matchId
    JOIN [user] u ON p.playerId = u.userId
    GROUP BY p.playerId, u.firstName, u.lastName;
GO
--Executing the View
SELECT * FROM PlayerPerformance

-- 2. Creating view for a detailed contact information of team staff
GO

CREATE OR ALTER VIEW DetailedContractInfo AS 
    SELECT c.contractId, c.description, c.startDate, c.endDate, t.teamName, 
            ts.playingCountry, u.firstName + ' ' + u.lastName AS staffName, 
            CASE WHEN c.isTeamCaptain = 1 THEN 'Yes' ELSE 'No' END AS isTeamCaptain
    FROM [contract] c 
    JOIN [team] t ON c.teamId = t.teamId 
    JOIN [teamStaff] ts ON c.teamStaffId = ts.teamStaffId 
    JOIN [user] u ON ts.teamStaffId = u.userId;

GO
--Executing the View
SELECT * FROM DetailedContractInfo

GO
-- 3. Creating view for the preference transaction of a user
CREATE OR ALTER VIEW ViewerPreferencesTransactions AS 
    SELECT v.viewerId, u.firstName + ' ' + u.lastName AS viewerName, v.favoriteTeam, v.languagePreference, 
            COUNT(t.transactionId) AS numberOfTransactions, SUM(t.amount) AS totalSpent
    FROM [viewer] v
    JOIN [user] u ON v.viewerId = u.userId
    LEFT JOIN [transaction] t ON v.viewerId = t.viewerId
    GROUP BY v.viewerId, u.firstName, u.lastName, v.favoriteTeam, v.languagePreference;

GO
--Executing the view
SELECT * FROM ViewerPreferencesTransactions

--#######USER DEFINED FUNCTIONS########
--1.Create a UDF that takes a playerId and matchId as input and returns the total minutes played by that player in that specific match
GO
CREATE OR ALTER FUNCTION dbo.GetPlayerMatchMinutes (@playerId INT, @matchId INT)
RETURNS INT
AS
BEGIN
    DECLARE @minutesPlayed INT

    SELECT @minutesPlayed = minutesPlayed
    FROM [player]
    INNER JOIN [playerStatistics] ON [player].playerId = [playerStatistics].playerId
    WHERE [player].playerId = @playerId AND [playerStatistics].matchPlayerId = @matchId

    RETURN ISNULL(@minutesPlayed, 0)
END
GO

SELECT * from player
SELECT * from [match]

--- Executing the function 
DECLARE @playerId INT = 1001; 
DECLARE @matchId INT = 1; 

SELECT dbo.GetPlayerMatchMinutes(@playerId, @matchId) AS MinutesPlayed;


--2. To get match details including stadium information
GO
CREATE OR ALTER FUNCTION dbo.GetMatchStadiumInfo(@matchId INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        m.matchId,
        m.matchDate,
        t1.teamName AS homeTeam,
        t2.teamName AS awayTeam,
        s.stadiumName,
        s.location AS stadiumLocation
    FROM
        [match] m
    INNER JOIN
        [team] t1 ON m.homeTeamId = t1.teamId
    INNER JOIN
        [team] t2 ON m.awayTeamId = t2.teamId
    INNER JOIN
        [stadium] s ON m.stadiumId = s.stadiumId
    WHERE
        m.matchId = @matchId
);
GO
--- Executing the function
DECLARE @matchIdToQuery INT = 1; 
SELECT * FROM dbo.GetMatchStadiumInfo(@matchIdToQuery);

---3. UDF to calculate the years of experience (Used in inserting admin data)
GO

CREATE OR ALTER FUNCTION dbo.CalculateYearsOfExperience (@JoiningDate DATE)
    RETURNS INT
AS
BEGIN
    DECLARE @CurrentDate DATE = GETDATE();
    RETURN DATEDIFF(YEAR, @JoiningDate, @CurrentDate);
END

GO

SELECT dbo.CalculateYearsOfExperience('2021-01-15') AS Years_Of_Experience
SELECT dbo.CalculateYearsOfExperience('2016-03-18') AS Years_Of_Experience



--1. ######### CREATING THE TRIGGER ON USER INSERTION #########
CREATE TABLE UserAudit (
    AuditId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    AuditAction NVARCHAR(255),
    AuditTimestamp DATETIME DEFAULT GETDATE()
);
GO

--Trigger Creation
CREATE TRIGGER trgAfterInsertUser ON [user]
AFTER INSERT
AS
BEGIN
    -- Insert a record into UserAudit for each new user
    INSERT INTO UserAudit(UserId, AuditAction)
    SELECT userId, 'New user added' FROM inserted;
END;
GO

--password
OPEN SYMMETRIC KEY userPass_SM
DECRYPTION BY CERTIFICATE userPass;

    INSERT INTO [user] (userEmail, firstName, lastName, [password], streetName, [state], country, postalCode, userType)
      VALUES
        ('rishabh.kesarwani@example.com', 'Rishabh', 'kesarwani', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), '123 Main St', 'CA', 'USA', '12345', 'TeamStaff');

GO

--Executing the trigger
SELECT * FROM UserAudit

-- 2. ######### CREATING THE TRIGGER ON UPDATION OF STADIUM FOR A MATCH #########
CREATE TABLE MatchStadiumAudit (
  auditId INT PRIMARY KEY IDENTITY(1,1),
  matchId INT,
  oldStadiumId INT,
  oldStadiumName NVARCHAR(100),
  oldStadiumLocation NVARCHAR(100),
  newStadiumId INT,
  newStadiumName NVARCHAR(100),
  newStadiumLocation NVARCHAR(100),
  updateDate DATETIME
)

GO

--Creating trigger
CREATE OR ALTER TRIGGER trgMatchStadiumUpdate ON [match]
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  IF UPDATE(stadiumId)
  BEGIN
    INSERT INTO MatchStadiumAudit (
      matchId,
      oldStadiumId,
      oldStadiumName,
      oldStadiumLocation,
      newStadiumId,
      newStadiumName,
      newStadiumLocation,
      updateDate
    )
    SELECT
      i.matchId,
      d.stadiumId AS oldStadiumId,
      s_d.stadiumName AS oldStadiumName,
      s_d.[location] AS oldStadiumLocation,
      i.stadiumId AS newStadiumId,
      s_i.stadiumName AS newStadiumName,
      s_i.[location] AS newStadiumLocation,
      GETDATE() AS updateDate
    FROM inserted i
    INNER JOIN deleted d ON i.matchId = d.matchId 
    JOIN stadium s_d ON d.stadiumId = s_d.stadiumId 
    JOIN stadium s_i ON i.stadiumId = s_i.stadiumId 
    WHERE i.stadiumId <> d.stadiumId;
  END
END

GO

-- Validate the initial state
SELECT * FROM MatchStadiumAudit;

-- Update the stadiumId for the match
UPDATE [match] SET stadiumId = 1 WHERE matchId = 3;

-- Validate the changes captured by the trigger
SELECT * FROM MatchStadiumAudit;



-- ######### VALIDATING COLUMN LEVEL CHECK CONSTRAINTS #########
-- All statements should fail
-- 1. Check constraint for the years of experience
INSERT INTO [admin] (adminId, adminRole, adminPermissions, joiningDate, yearsOfExperience, lastLogin) 
VALUES (106, 'Data Analyst', 'Read Access', '2021-06-15', -1, '2023-03-01 09:00:00')

-- 2. Validating constraints for negative amount queries
INSERT INTO [transaction] (matchId, viewerId, amount, paymentMode, transactionTime)
VALUES (2, 1002, -20.00, 'PayPal', '2023-01-02 15:30:00')

-- 3. Validating constraints for invalid date queries
INSERT INTO [transaction] (matchId, viewerId, amount, paymentMode, transactionTime)
VALUES (4, 1004, 40.00, 'Credit Card', '2024-12-31 22:00:00')

-- ######### REFERENTIAL INTEGRITY #########

ALTER TABLE [viewer]
ADD CONSTRAINT FK_Viewer_User 
FOREIGN KEY (viewerId) REFERENCES [user](userId) ON DELETE CASCADE;

ALTER TABLE [transaction]
ADD CONSTRAINT FK_Transaction_User 
FOREIGN KEY (viewerId) REFERENCES [viewer](viewerId) ON DELETE CASCADE;

-- Validating referential integrity constraint
DELETE from [user] where userId = 1014
SELECT * FROM [user] where userId = 1014
SELECT * FROM [viewer] where viewerId = 1014
SELECT * FROM [transaction] where viewerId = 1014


-- ######## Non-clustered index ###############

-- Non clustered index 1: Create a nonclustered index on the "userType" column in the "user" table
CREATE NONCLUSTERED INDEX IX_User_UserType ON [user] (userType)

SELECT NAME AS index_name, type_desc AS index_type FROM sys.indexes WHERE object_id = Object_id('user')
SELECT * FROM [user] WHERE userType = 'Viewer'

-- Non clustered index 2: Create a nonclustered index on the "playerId, SkillId" column in the "playerSkills" table
CREATE NONCLUSTERED INDEX IX_PlayerSkills_PlayerId_SkillId ON [playerSkills] (playerId, skillId)

SELECT NAME AS index_name, type_desc AS index_type FROM sys.indexes WHERE object_id = Object_id('playerSkills')
SELECT * FROM [playerSkills] WHERE playerId = 1001 AND skillId = 1

-- Non clustered index 3: Create a nonclustered index on the "teamLocation" column in the "team" table
CREATE NONCLUSTERED INDEX IX_Team_TeamLocation ON [team] (teamLocation)

SELECT NAME AS index_name, type_desc AS index_type FROM sys.indexes WHERE object_id = Object_id('team')
SELECT * FROM [team] WHERE teamLocation = 'Boston'