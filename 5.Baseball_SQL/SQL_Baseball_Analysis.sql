SELECT *
FROM RaysPitching.dbo.LastPitchRays

SELECT *
FROM RaysPitching.dbo.RaysPitchingStats

						--Question 1 AVG Pitches Per at Bat Analysis
--1a AVG Pitches Per At Bat (LastPitchRays)
SELECT AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays

--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union
SELECT
	'Home' TypeofGame,
	AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays
WHERE home_team = 'TB'
UNION
SELECT
	'Away' TypeofGame,
	AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays
WHERE away_team = 'TB'

--1c AVG Pitches Per At Bat Lefty Vs Righty  -> Case Statement
SELECT
	'Righty' BatterPosition,
	AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays
WHERE Batter_position= 'R'
UNION
SELECT
	'Lefty' BatterPosition,
	AVG(1.00 * pitch_number) AvgNumofPitchesPerAtBat
FROM RaysPitching.dbo.LastPitchRays
WHERE Batter_position = 'L'

--Case Statement
SELECT
	AVG(Case when batter_position = 'L' Then 1.00 * pitch_number end) LeftyatBats,
	AVG(Case when batter_position = 'R' Then 1.00 * pitch_number end) RightyatBats
FROM RaysPitching.dbo.LastPitchRays

--1d AVG Pitches Per At Bat Lefty Vs Righty Pitcher | Each Away Team -> Partition By
SELECT DISTINCT
	home_team,
	Pitcher_position,
	AVG(1.00 * pitch_number) OVER (Partition by home_team, Pitcher_position)
FROM RaysPitching.dbo.LastPitchRays
WHERE away_team = 'TB'

--1e Top 3 Most Common Pitch for at bat 1 through 10, and total amounts (LastPitchRays)
WITH totalpitchsequence AS (
	SELECT DISTINCT
		pitch_name,
		pitch_number,
		COUNT(pitch_name) OVER (Partition by pitch_name, pitch_number) PitchFrequency
	FROM RaysPitching.dbo.LastPitchRays
	WHERE pitch_number < 11
) ,
pitchfrequencyrankquery AS (
	SELECT 
		pitch_name,
		pitch_number,
		PitchFrequency,
		rank() OVER (Partition by pitch_number order by PitchFrequency desc) PitchFrequencyRanking
	FROM totalpitchsequence
)
SELECT *
FROM pitchfrequencyrankquery
WHERE PitchFrequencyRanking < 4

--1f AVG Pitches Per at Bat Per Pitcher with 20+ Innings | Order in descending (LastPitchRays + RaysPitchingStats)


SELECT 
	RPS.Name,
	AVG(1.00 * pitch_number) AVGPitches
FROM RaysPitching.dbo.LastPitchRays LPR
JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
WHERE IP >= 20
GROUP BY RPS.Name
ORDER BY AVG(1.00 * pitch_number) DESC


						--Question 2 Last Pitch Analysis
--2a Count of the Last Pitches Thrown in Desc Order (LastPitchRays)

SELECT pitch_name, COUNT(*)
FROM RaysPitching.dbo.LastPitchRays
GROUP BY pitch_name
ORDER BY COUNT(*) DESC

--2b Count of the different last pitches Fastball or Offspeed (LastPitchRays)
SELECT 
	SUM(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) Fastball,
	SUM(case when pitch_name NOT in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) Offspeed
FROM RaysPitching.dbo.LastPitchRays

--2c Percentage of the different last pitches Fastball or Offspeed (LastPitchRays)
SELECT 
	100 * SUM(case when pitch_name in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) / COUNT(*) FastballPercent,
	100 * SUM(case when pitch_name NOT in ('4-Seam Fastball', 'Cutter') then 1 else 0 end) / COUNT(*) OffspeedPercent
FROM RaysPitching.dbo.LastPitchRays


-- 2d Top 5 Most common last pitch for a Relief Pitcher vs Starting Pitcher (LastPitchRays + RaysPitchingStats)
WITH PitchRanking AS (
	SELECT
		pitch.Pos,
		pitch.pitch_name,
		pitch.TimesThrown,
		RANK() OVER (Partition by pitch.Pos Order by pitch.TimesThrown desc) PitchRank
	FROM(
		SELECT 
			RPS.POS, 	
			LPR.pitch_name,
			COUNT(*) TimesThrown
		FROM RaysPitching.dbo.LastPitchRays LPR
		JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
		GROUP BY RPS.POS, LPR.pitch_name
	) pitch
)
SELECT *
FROM PitchRanking
WHERE PitchRank < 6


					--Question 3 Homerun analysis
--3a What pitches have given up the most HRs (LastPitchRays) 
SELECT 
	pitch_name, COUNT(*) HRs
FROM RaysPitching.dbo.LastPitchRays
WHERE events = 'home_run'
GROUP BY pitch_name
ORDER BY COUNT(*) DESC

--3b Show HRs given up by zone and pitch, show top 5 most common
SELECT TOP 5
	pitch_name,
	zone,
	COUNT(*) HRS
FROM RaysPitching.dbo.LastPitchRays
WHERE events = 'home_run'
GROUP BY pitch_name, zone
ORDER BY COUNT(*) DESC

--3c Show HRs for each count type -> Balls/Strikes + Type of Pitcher
SELECT 
	RPS.Pos,
	LPR.balls,
	LPR.strikes,
	COUNT(*) HRS
FROM RaysPitching.dbo.LastPitchRays LPR
JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
WHERE events = 'home_run'
GROUP BY RPS.Pos, LPR.balls,LPR.strikes
ORDER BY COUNT(*) DESC

--3d Show Each Pitchers Most Common count to give up a HR (Min 30 IP)
WITH hrcounpitchers AS (
	SELECT 
		RPS.Name,
		LPR.balls,
		LPR.strikes,
		COUNT(*) HRS
	FROM RaysPitching.dbo.LastPitchRays LPR
	JOIN RaysPitching.dbo.RaysPitchingStats RPS ON RPS.pitcher_id = LPR.pitcher
	WHERE events = 'home_run' and RPS.IP >= 30
	GROUP BY RPS.Name,  LPR.balls,LPR.strikes
),
HRcountrank AS(
	SELECT 
		Name,
		balls,
		strikes,
		HRS,
		RANK() OVER (Partition by Name order by HRS desc) HRrank
	FROM hrcounpitchers hcp
)
SELECT 
	Name,
		balls,
		strikes,
		HRS	
FROM HRcountrank
WHERE HRrank = 1

						--Question 4 Shane McClanahan
--4a AVG Release speed, spin rate,  strikeouts, most popular zone ONLY USING LastPitchRays
SELECT 
	AVG(release_speed) AvgReleaseSpeed,
	AVG(release_spin_rate) AvgSpinRate,
	SUM(case when events = 'strikeout' then 1 else 0 end) strikeouts,
	MAX(Zones.zone) as Zone
FROM RaysPitching.dbo.LastPitchRays LPR
JOIN (
	SELECT TOP 1 pitcher, zone, count(*) zonenum
	FROM RaysPitching.dbo.LastPitchRays LPR
	where player_name = 'McClanahan, Shane'
	GROUP BY pitcher,zone	
	ORDER BY count(*) desc
) Zones on Zones.pitcher = LPR.pitcher
where player_name = 'McClanahan, Shane'

--4b top pitches for each infield position where total pitches are over 5, rank them
SELECT *
FROM (
	SELECT pitch_name, Count(*) timeshit, 'Third' Position
	FROM RaysPitching.dbo.LastPitchRays
	WHERE hit_location = 5 and player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, Count(*) timeshit, 'Short' Position
	FROM RaysPitching.dbo.LastPitchRays
	WHERE hit_location = 6 and player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, Count(*) timeshit, 'Second' Position
	FROM RaysPitching.dbo.LastPitchRays
	WHERE hit_location = 4 and player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
	UNION
	SELECT pitch_name, Count(*) timeshit, 'First' Position
	FROM RaysPitching.dbo.LastPitchRays
	WHERE hit_location = 3 and player_name = 'McClanahan, Shane'
	GROUP BY pitch_name
) A
WHERE timeshit > 4
ORDER BY timeshit desc

--4c Show different balls/strikes as well as frequency when someone is on base 
SELECT balls, strikes, COUNT(*) frequency
FROM RaysPitching.dbo.LastPitchRays
WHERE (on_3b is NOT NULL or on_2b is NOT NULL or on_1b is NOT NULL) 
and player_name = 'McClanahan, Shane'
GROUP BY balls, strikes
ORDER BY COUNT(*) desc

--4d What pitch causes the lowest launch speed
SELECT TOP 1 pitch_name, AVG(launch_speed*1.00) LaunchSpeed
FROM RaysPitching.dbo.LastPitchRays
WHERE player_name = 'McClanahan, Shane'
GROUP BY pitch_name
ORDER BY AVG(launch_speed) 