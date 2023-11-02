-- Создание файлов Match.csv и Team.csv 

-- 1.  Оброботка таблицы Match. Добавление информации о названиях стран, лиг, домашних команд и исключение лишних столбцов
WITH New_match AS 
(SELECT 
match_api_id, 
Country.id AS country_league_id, 
Country.name AS country_name,
League.name AS league_name,
season,
home_team_api_id,
team_long_name AS home_team_long_name,
team_short_name AS home_team_short_name,
away_team_api_id,
home_team_goal,
away_team_goal
FROM Match
INNER JOIN Country
ON Match.country_id = Country.id
INNER JOIN League
ON Match.country_id = League.country_id
INNER JOIN Team
ON Match.home_team_api_id = Team.team_api_id),

-- 2.  Добавление информации о названии гостевых команд 
New_match_2 AS
(SELECT 
match_api_id, 
country_league_id, 
country_name,
league_name,
season,
home_team_api_id,
home_team_long_name,
home_team_short_name,
away_team_api_id,
Team.team_long_name AS away_team_long_name,
Team.team_short_name AS away_team_short_name,
home_team_goal,
away_team_goal
FROM  New_Match
INNER JOIN Team
ON New_Match.away_team_api_id = Team.team_api_id);


-- 3.  Оброботка таблицы Team_Attributes. Добавление информации о названиях стран, лиг и команд и исключение лишних столбцов
New_Team AS
(SELECT
team.team_api_id,
team_long_name,
team_short_name,
country_name,
league_name,
data,
buildUpPlaySpeed,
buildUpPlaySpeedClass,
buildUpPlayDribbling,
buildUpPlayDribblingClass,
buildUpPlayPassing,
buildUpPlayPassingClass,
buildUpPlayPositioningClass,
chanceCreationPassing,
chanceCreationPassingClass,
chanceCreationCrossing,
chanceCreationCrossingClass,
chanceCreationShooting,
chanceCreationShootingClass,
chanceCreationPositioningClass,
defencePressure,
defencePressureClass,
defenceAggression,
defenceAggressionClass,
defenceTeamWidth,
defenceTeamWidthClass,
defenceDefenderLineClass
FROM Team_Attributes
INNER JOIN Team
ON Team_Attributes.team_api_id = Team.team_api_id
INNER JOIN New_match_2
ON Team_Attributes.team_api_id = New_match_2.home_team_api_id)

-- 4.  Группировка столбца date по сезонам
SELECT DISTINCT *, 
CASE 
	WHEN DATE(date) < '2009-06' THEN '2008/2009'
    WHEN DATE(date) > '2009-06' and DATE(date) < '2010-06' THEN '2009/2010'
    WHEN DATE(date) > '2010-06' and DATE(date) < '2011-06' THEN '2010/2011'
    WHEN DATE(date) > '2011-06' and DATE(date) < '2012-06' THEN '2011/2012'
    WHEN DATE(date) > '2012-06' and DATE(date) < '2013-06' THEN '2012/2013'
    WHEN DATE(date) > '2013-06' and DATE(date) < '2014-06' THEN '2013/2014'
    WHEN DATE(date) > '2014-06' and DATE(date) < '2015-06' THEN '2014/2015'
    ELSE '2015/2016'
END
AS season 
FROM New_Team;


--Создание файла Player.csv

-- 1. Оброботка таблицы Match. Объединение состава команд 
WITH Union_players AS
(SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_1, away_player_1
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_2, away_player_2
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_3, away_player_3
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_4, away_player_4
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_5, away_player_5
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_6, away_player_6
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_7, away_player_7
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_8, away_player_8
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_9, away_player_9
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_10, away_player_10
FROM Match
UNION
SELECT season, country_id, home_team_api_id, away_team_api_id, home_player_11, away_player_11
FROM Match),

-- 2. Создание таблицы всех игроков, участвующих в матче в разрезе команд и сезонов
Players_all AS
(SELECT * FROM (SELECT season, country_id, home_team_api_id AS Team_id, home_player_1 AS Player_id
FROM Union_players
UNION 
SELECT season, country_id, away_team_api_id, away_player_1
FROM Union_players)
WHERE Player_id IS NOT NULL),

-- 3. Добавление информации о названиях стран, лиг и команд 
Players_all_add_info AS
(SELECT season, Players_all.country_id, Country.name AS country_name, League.name AS league_name, Team_id, team_long_name, team_short_name, Player_id 
FROM Players_all
INNER JOIN Country
ON Players_all.country_id = Country.id
INNER JOIN League
ON Players_all.country_id = League.id
INNER JOIN Team
ON Players_all.Team_id = Team.team_api_id),


-- 4. Оброботка таблицы Player_Attributes. Группировка столбца date по сезонам
Player_add_season AS
(SELECT player_api_id, overall_rating, potential, DATE(date) AS Date,
CASE 
	WHEN DATE(date) < '2009-06' THEN '2008/2009'
    WHEN DATE(date) > '2009-06' and DATE(date) < '2010-06' THEN '2009/2010'
    WHEN DATE(date) > '2010-06' and DATE(date) < '2011-06' THEN '2010/2011'
    WHEN DATE(date) > '2011-06' and DATE(date) < '2012-06' THEN '2011/2012'
    WHEN DATE(date) > '2012-06' and DATE(date) < '2013-06' THEN '2012/2013'
    WHEN DATE(date) > '2013-06' and DATE(date) < '2014-06' THEN '2013/2014'
    WHEN DATE(date) > '2014-06' and DATE(date) < '2015-06' THEN '2014/2015'
    ELSE '2015/2016'
END
AS season
FROM Player_Attributes
WHERE overall_rating is NOT NULL),

-- 5. Добавление информации об имени игрока и дате рождения 
Player_all_info AS
(SELECT Player.player_api_id, player_name, birthday,overall_rating, potential, Date, season
 FROM Player_add_season
 INNER JOIN Player
 ON Player_add_season.player_api_id = Player.player_api_id)

-- 6. Объединение таблиц Player_all_info (шаг 5) и Players_all_add_info (шаг 3)
SELECT DISTINCT * FROM (SELECT 
Player_all_info.player_api_id,
player_name,
birthday,
overall_rating,
potential,
Date,
Player_all_info.season,
Team_id AS team_api_id,
team_long_name,
team_short_name,
country_name,
league_name
FROM Player_all_info
LEFT JOIN  Players_all_add_info
ON Player_all_info.player_api_id =  Players_all_add_info.Player_id AND  Player_all_info.season = Players_all_add_info.season)
Order BY player_api_id;

 