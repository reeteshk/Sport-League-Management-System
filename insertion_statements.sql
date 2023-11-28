GO

USE sportsleaguemgmtsys

GO

-- ######### IMPLEMENTING THE COLUMN LEVEL ENCRYPTION #########

--Column data encrpytion for Password field in User table
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Dmdd@sportsleague';

--Verifying master key
SELECT name KeyName,
symmetric_key_id KeyID,
key_length KeyLength,
algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

GO

-- Creating certificate
CREATE CERTIFICATE userPass
WITH SUBJECT = 'User Sample Password';

GO

-- Creating symmetric key for encrypting and decrypting using same key
CREATE SYMMETRIC KEY userPass_SM
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE userPass;

GO

OPEN SYMMETRIC KEY userPass_SM
DECRYPTION BY CERTIFICATE userPass;

GO

-- ######### INSERTING VALUES IN THE USER TABLE #########
GO


INSERT INTO [user] (userEmail, firstName, lastName, [password], streetName, [state], country, postalCode, userType)
VALUES
    ('michael.johnson@gmail.com', 'Michael', 'Johnson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player1 Street', 'CA', 'USA', '11111', 'TeamStaff'),
    ('david.smith@gmail.com', 'David', 'Smith', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player2 Street', 'NY', 'USA', '22222', 'TeamStaff'),
    ('christopher.williams@gmail.com', 'Christopher', 'Williams', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player3 Street', 'TX', 'USA', '33333', 'TeamStaff'),
    ('matthew.brown@gmail.com', 'Matthew', 'Brown', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player4 Street', 'FL', 'USA', '44444', 'TeamStaff'),
    ('daniel.miller@gmail.com', 'Daniel', 'Miller', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player5 Street', 'AZ', 'USA', '55555', 'TeamStaff'),
    ('andrew.davis@gmail.com', 'Andrew', 'Davis', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player6 Street', 'WA', 'USA', '66666', 'TeamStaff'),
    ('joseph.wilson@gmail.com', 'Joseph', 'Wilson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player7 Street', 'GA', 'USA', '77777', 'TeamStaff'),
    ('ryan.moore@gmail.com', 'Ryan', 'Moore', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player8 Street', 'NC', 'USA', '88888', 'TeamStaff'),
    ('nicholas.taylor@gmail.com', 'Nicholas', 'Taylor', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player9 Street', 'CO', 'USA', '99999', 'TeamStaff'),
    ('brandon.anderson@gmail.com', 'Brandon', 'Anderson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player10 Street', 'OR', 'USA', '10101', 'TeamStaff'),
    ('jennifer.anderson@yahoo.com', 'Jennifer', 'Anderson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Coach1 Street', 'MA', 'USA', '12121', 'Admin'),
    ('jonathan.harris@yahoo.com', 'Jonathan', 'Harris', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Coach2 Street', 'MA', 'USA', '13131', 'Admin'),
    ('william.harrison@gmail.com', 'William', 'Harrison', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Coach3 Street', 'MA', 'USA', '14141', 'TeamStaff'),
    ('joseph.mitchell@gmail.com', 'Joseph', 'Mitchell', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Coach4 Street', 'MA', 'USA', '15151', 'TeamStaff'),
    ('frank.henderson@yahoo.com', 'Frank', 'Henderson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player27 Street', 'CA', 'USA', '16161', 'Viewer'),
    ('matthew.russell@yahoo.com', 'Matthew', 'Russell', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player28 Street', 'NY', 'USA', '17171', 'Admin'),
    ('harry.barnes@gmail.com', 'Harry', 'Barnes', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player29 Street', 'TX', 'USA', '18181', 'Viewer'),
    ('eugene.alexander@yahoo.com', 'Eugene', 'Alexander', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player30 Street', 'FL', 'USA', '19191', 'Admin'),
    ('john.anderson@gmail.com', 'John', 'Anderson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player31 Street', 'CA', 'USA', '20202', 'TeamStaff'),
    ('robert.lee@gmail.com', 'Robert', 'Lee', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player32 Street', 'NY', 'USA', '21212', 'TeamStaff'),
    ('william.white@gmail.com', 'William', 'White', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player33 Street', 'TX', 'USA', '22222', 'Viewer'),
    ('brian.johnson@gmail.com', 'Brian', 'Johnson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player34 Street', 'FL', 'USA', '23232', 'TeamStaff'),
    ('eric.anderson@gmail.com', 'Eric', 'Anderson', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player35 Street', 'AZ', 'USA', '24242', 'Viewer'),
    ('steven.clark@gmail.com', 'Steven', 'Clark', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player36 Street', 'WA', 'USA', '25252', 'TeamStaff'),
    ('james.jones@yahoo.com', 'James', 'Jones', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player37 Street', 'GA', 'USA', '26262', 'TeamStaff'),
    ('robert.lee@yahoo.com', 'Robert', 'Lee', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player38 Street', 'NC', 'USA', '27272', 'Viewer'),
    ('william.white@gmail.com', 'William', 'White', ENCRYPTBYKEY(Key_GUID('userPass_SM'), convert(varbinary,'damg6210')), 'Player39 Street', 'CO', 'USA', '95761', 'TeamStaff');

select * from [user]

-- ######### FUNCTION FOR CALCULATING THE YEARS OF EXPERIENCE #########
GO

        CREATE OR ALTER FUNCTION dbo.CalculateYearsOfExperience (@JoiningDate DATE)
        RETURNS INT
        AS
        BEGIN
            DECLARE @CurrentDate DATE = GETDATE();

            RETURN DATEDIFF(YEAR, @JoiningDate, @CurrentDate);
        END

GO

-- ######### INSERTING THE VALUES IN THE ADMIN TABLE #########
INSERT INTO [admin] (adminId, adminRole, adminPermissions, joiningDate, yearsOfExperience, lastLogin)
VALUES 
    (1010, 'Head Admin', 'Master', '2019-05-20', dbo.CalculateYearsOfExperience('2019-05-20'), GETDATE()),
    (1011, 'Head Admin', 'Master', '2021-01-15', dbo.CalculateYearsOfExperience('2021-01-15'), GETDATE()),
    (1015, 'Head Admin', 'Master', '2017-03-10', dbo.CalculateYearsOfExperience('2017-03-10'), GETDATE()),
    (1017, 'Head Admin', 'Master', '2016-03-18', dbo.CalculateYearsOfExperience('2016-03-18'), GETDATE());

SELECT * FROM [admin]

-- ######### INSERTING THE VALUES IN THE TEAMSTAFF TABLE #########
INSERT INTO [teamStaff] (teamStaffId,playingCountry,staffType) 
VALUES (1000,'USA','Coach'),
        (1001,'USA','Player'),
		(1002,'USA', 'Player'),
		(1003,'USA', 'Player'),
		(1004,'USA', 'Player'),
		(1005,'USA', 'Player'),
		(1006,'USA', 'Player'),
		(1007,'USA', 'Player'),
		(1008,'USA', 'Player'),
		(1009,'USA', 'Player'),
		(1018,'USA', 'Player'),
		(1019,'USA', 'Player'),
		(1021,'USA', 'Player'),
		(1023,'USA', 'Player'),
		(1024,'USA', 'Player'),
		(1026,'USA', 'Player'),
		(1012,'USA', 'Coach'),
		(1013,'USA', 'Coach');

select * from [teamStaff]

-- ######### INSERTING THE VALUES IN THE VIEWER TABLE #########
INSERT INTO [viewer] (viewerId, favoriteTeam, languagePreference)
VALUES
    (1014, 'Red Sox', 'German'),
    (1016, 'Yankees', 'English'),
    (1020, 'Red Sox', 'Spanish'),
    (1022, 'Yankees', 'French'),
    (1025, 'Red Sox', 'German');
SELECT * FROM [viewer]

-- ######### INSERTING THE VALUES IN THE PLAYER TABLE #########
INSERT INTO [player] (playerId, position, isSubstitute, minutesPlayed)
VALUES
    (1001, 'Pitcher', 0, 102),
    (1002, 'Catcher', 1, 75),
    (1003, 'First Baseman', 0, 120),
    (1004, 'Second Baseman', 1, 90),
    (1005, 'Third Baseman', 0, 105),
    (1006, 'Shortstop', 0, 110),
    (1007, 'Left Fielder', 1, 80),
    (1008, 'Center Fielder', 0, 115),
    (1009, 'Right Fielder', 1, 88),
    (1018, 'Pitcher', 0, 98),
    (1019, 'Catcher', 1, 72),
    (1021, 'First Baseman', 0, 118),
    (1023, 'Second Baseman', 1, 82),
    (1024, 'Third Baseman', 0, 100),
    (1026, 'Shortstop', 0, 105);

SELECT * FROM [player]

-- ######### INSERTING THE VALUES IN THE COACH TABLE #########
INSERT INTO [coach] (coachId, coachingExperience, specialization, coachingPhilosophy) 
VALUES (1001, 5, 'Pitching and bullpen', 'Strong leadership skills'),
    (1012, 8, 'Hitting and offense', 'Emphasizes player development and teamwork'),
    (1013, 10, 'Fielding and defense', 'Believes in a strategic and adaptive coaching approach')

SELECT * FROM [coach]

-- ######### INSERTING THE VALUES IN THE SKILLS TABLE #########
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

-- ######### INSERTING THE VALUES IN THE PLAYERSKILLS TABLE #########
 INSERT INTO [playerSkills] (playerId, skillId)
VALUES
  (1001, 1),
  (1001, 2),
  (1001, 10),
  (1002, 3),
  (1003, 8),
  (1003, 10),
  (1003, 9),
  (1004, 6),
  (1005, 5),
  (1006, 2),
  (1007, 7),
  (1008, 9),
  (1009, 10),
  (1018, 4),
  (1019, 6),
  (1021, 1),
  (1023, 8),
  (1024, 3),
  (1026, 5);

SELECT * FROM playerSkills

-- ######### INSERTING THE VALUES IN THE TEAM TABLE #########
INSERT INTO [team] (teamId, teamName, teamLocation, sponsorship) 
VALUES (1, 'RedSoX', 'Boston', 'MassMutual'), 
        (2, 'Yankees', 'New York', 'Starr insurance')
SELECT * FROM TEAM

-- ######### INSERTING THE VALUES IN THE CONTRACT TABLE #########
INSERT INTO [contract] ([description], startDate, endDate, teamId, teamStaffId, isTeamCaptain)
VALUES
    ('Team Captain Contract for Player 1001', '2023-01-01', '2023-12-31', 1, 1001, 1), 
    ('Team Captain Contract for Player 1018', '2023-01-01', '2023-12-31', 2, 1018, 1),
	('Player Contract for Player 1002', '2023-01-01', '2023-12-31', 1, 1002, 0),
    ('Player Contract for Player 1003', '2023-01-01', '2023-12-31', 1, 1003, 0),
    ('Player Contract for Player 1004', '2023-01-01', '2023-12-31', 1, 1004, 0),
    ('Player Contract for Player 1005', '2023-01-01', '2023-12-31', 1, 1005, 0),
    ('Player Contract for Player 1006', '2023-01-01', '2023-12-31', 1, 1006, 0),
    ('Player Contract for Player 1007', '2023-01-01', '2023-12-31', 1, 1007, 0),
    ('Player Contract for Player 1008', '2023-01-01', '2023-12-31', 1, 1008, 0),
    ('Player Contract for Player 1009', '2023-01-01', '2023-12-31', 1, 1009, 0),
	('Player Contract for Player 1019', '2023-01-01', '2023-12-31', 2, 1019, 0),
    ('Player Contract for Player 1021', '2023-01-01', '2023-12-31', 2, 1021, 0),
    ('Player Contract for Player 1023', '2023-01-01', '2023-12-31', 2, 1023, 0),
    ('Player Contract for Player 1024', '2023-01-01', '2023-12-31', 2, 1024, 0),
    ('Player Contract for Player 1026', '2023-01-01', '2023-12-31', 2, 1026, 0),
	('Coach Contract for Coach 1012', '2023-01-01', '2023-12-31', 1, 1012, 0),
    ('Coach Contract for Coach 1013', '2023-01-01', '2023-12-31', 2, 1013, 0),
	('Coach Contract for Coach 1001', '2023-01-01', '2023-12-31', 1, 1012, 0);
    
SELECT * FROM [contract]

-- ######### INSERTING THE VALUES IN THE STADIUM TABLE #########
INSERT INTO [stadium] (stadiumId, stadiumName, [location], capacity, adminId)
VALUES
    (1, 'Olympic Stadium', 'City Center', 70000, 1010),
    (2, 'National Stadium', 'Downtown', 50000, 1011),
    (3, 'City Arena', 'Midtown', 60000, 1015),
    (4, 'Greenfield Park', 'Suburb', 55000, 1017);

SELECT * from stadium

-- ######### INSERTING THE VALUES IN THE MATCH TABLE #########
INSERT INTO [match] (matchId, matchDate, homeTeamId, AwayTeamId, stadiumId, winningTeam)
VALUES
  (1, '2023-08-01T15:00:00', 1, 2, 1, 1),
  (2, '2022-08-02T18:00:00', 2, 1, 2, 2),
  (3, '2023-08-03T20:00:00', 1, 2, 3, 1),
  (4, '2023-08-04T17:00:00', 2, 1, 2, 2);

GO

select * from [match]

-- ######### INSERTING THE VALUES IN THE PLAYER STATISTICS TABLE #########
INSERT INTO [playerStatistics] (playerStatsId, matchPlayerId, playerId, score) VALUES
(1, 1, 1001, 15),
  (2, 2, 1002, 20),
  (3, 3, 1003, 18),
  (4, 4, 1004, 12),
  (5, 1, 1005, 25),
  (6, 2, 1006, 10),
  (7, 3, 1007, 22),
  (8, 4, 1008, 18),
  (9, 1, 1009, 14),
  (10, 1, 1018, 17),
  (11, 2, 1019, 21),
  (12, 3, 1021, 19),
  (13, 4, 1023, 16),
  (14, 1, 1024, 23),
  (15, 2, 1026, 20);

SELECT * from playerStatistics join contract on playerStatistics.playerId=contract.teamStaffId join team on team.teamId=contract.teamId

-- ######### INSERTING THE VALUES IN THE TRANSACTION TABLE #########
INSERT INTO [transaction] (matchId, viewerId, amount, paymentMode, transactionTime)
VALUES
    (1, 1014, 30, 'Credit Card', '2023-07-31T15:00:00'),
    (2, 1016, 25, 'PayPal', '2023-08-01T18:00:00'),
    (3, 1020, 35, 'Venmo', '2021-08-02T20:00:00'),
    (4, 1022, 40, 'Credit Card', '2023-08-03T17:00:00'),
    (1, 1025, 30, 'PayPal', '2020-08-04T19:30:00'),
    (2, 1014, 25, 'Venmo', '2020-08-05T12:45:00'),
    (3, 1016, 35, 'Credit Card', '2021-08-06T16:30:00'),
    (4, 1020, 40, 'PayPal', '2022-08-07T14:15:00'),
    (1, 1022, 30, 'Venmo', '2023-08-08T19:00:00'),
    (2, 1025, 25, 'Credit Card', '2022-08-09T20:30:00'),
    (3, 1014, 35, 'PayPal', '2022-08-10T17:45:00'),
    (4, 1016, 40, 'Venmo', '2021-08-11T14:00:00'),
    (1, 1020, 30, 'Credit Card', '2021-08-12T16:30:00'),
    (2, 1022, 25, 'PayPal', '2023-08-13T18:15:00'),
    (3, 1025, 35, 'Venmo', '2023-08-14T19:45:00')

SELECT * FROM [transaction]

-- ######### ALL TABLE VIEWS #########
select * from [admin]
select * from [coach]
select * from [contract]
select * from [match]
select * from [player]
select * from [playerSkills]
select * from [playerStatistics]
select * from [skills]
select * from [stadium]
select * from [team]
select * from [teamStaff]
select * from [transaction]
select * from [user]
select * from [viewer]





