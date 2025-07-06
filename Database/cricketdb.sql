-- Create the database (run this as a superuser)
-- Connect to the database
-- Create tables
CREATE TABLE players (
    player_ID INTEGER PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    Role VARCHAR(50)
);

CREATE TABLE coaches (
    coach_ID INTEGER PRIMARY KEY,
    coach_name VARCHAR(30) NOT NULL,
    experience INTEGER,
    rating NUMERIC(2,1)
);

CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY,
    team_name VARCHAR(20) NOT NULL,
    team_captain INTEGER,
    team_coach INTEGER,
    win_rate NUMERIC(4,2),
    FOREIGN KEY (team_captain) REFERENCES players(player_ID),
    FOREIGN KEY (team_coach) REFERENCES coaches(coach_id)
);

CREATE TABLE matches (
    Match_ID INTEGER PRIMARY KEY,
    Match_Date DATE NOT NULL,
    Team1 INTEGER NOT NULL,
    Team2 INTEGER NOT NULL,
    Venue VARCHAR(100),
    FOREIGN KEY (Team1) REFERENCES teams(team_id),
    FOREIGN KEY (Team2) REFERENCES teams(team_id)
);

CREATE TABLE batsman (
    Player_ID INTEGER PRIMARY KEY,
    Runs INTEGER DEFAULT 0,
    Fours INTEGER DEFAULT 0,
    Sixes INTEGER DEFAULT 0,
    centuries INTEGER DEFAULT 0,
    half_centuries INTEGER DEFAULT 0,
    double_centuries INTEGER DEFAULT 0,
    innings INTEGER DEFAULT 0,
    average NUMERIC(4,2),
    best_score INTEGER,
    strike_rate NUMERIC(4,2),
    motm INTEGER DEFAULT 0,
    FOREIGN KEY (Player_ID) REFERENCES players(player_ID)
);

CREATE TABLE bowler (
    Player_ID INTEGER PRIMARY KEY,
    Wickets INTEGER DEFAULT 0,
    fifers INTEGER DEFAULT 0,
    economy NUMERIC(4,2),
    best VARCHAR(10),
    innings INTEGER DEFAULT 0,
    motm INTEGER DEFAULT 0,
    FOREIGN KEY (Player_ID) REFERENCES players(player_ID)
);

CREATE TABLE results (
    Match_ID INTEGER PRIMARY KEY,
    Winning_Team INTEGER,
    Result_Type VARCHAR(50),
    FOREIGN KEY (Winning_Team) REFERENCES teams(team_id),
    FOREIGN KEY (Match_ID) REFERENCES matches(Match_ID)
);

CREATE TABLE innings (
    Match_ID INTEGER,
    Player_ID INTEGER,
    Runs INTEGER DEFAULT 0,
    Balls_Faced INTEGER DEFAULT 0,
    Fours INTEGER DEFAULT 0,
    Sixes INTEGER DEFAULT 0,
    runs_conceded INTEGER DEFAULT 0,
    wickets INTEGER DEFAULT 0,
    overs NUMERIC(2,1) DEFAULT 0,
    maidens INTEGER DEFAULT 0,
    PRIMARY KEY (Match_ID, Player_ID),
    FOREIGN KEY (Match_ID) REFERENCES matches(Match_ID),
    FOREIGN KEY (Player_ID) REFERENCES players(player_ID)
);

-- Create indexes for better performance
CREATE INDEX idx_player_id ON players(PLAYER_ID);
CREATE INDEX idx_team_id ON teams(team_id);
CREATE INDEX idx_match_id ON matches(Match_ID);
CREATE INDEX idx_innings_match_player ON innings(Match_ID, Player_ID);
CREATE INDEX idx_results_match ON results(Match_ID);

-- Creation ended

-- Insertion 
--players
INSERT INTO players (Player_ID, Name, Country, Role) VALUES
(1, 'Virat Kohli', 'India', 'Batsman'),
(2, 'Rohit Sharma', 'India', 'Batsman'),
(3, 'Jasprit Bumrah', 'India', 'Bowler'),
(4, 'Kane Williamson', 'New Zealand', 'Batsman'),
(5, 'Trent Boult', 'New Zealand', 'Bowler'),
(6, 'Joe Root', 'England', 'Batsman'),
(7, 'James Anderson', 'England', 'Bowler'),
(8, 'Steve Smith', 'Australia', 'Batsman'),
(9, 'Pat Cummins', 'Australia', 'Bowler'),
(10, 'Babar Azam', 'Pakistan', 'Batsman'),
(11, 'Shaheen Afridi', 'Pakistan', 'Bowler'),
(12, 'Quinton de Kock', 'South Africa', 'Wicket-keeper Batsman'),
(13, 'Kagiso Rabada', 'South Africa', 'Bowler'),
(14, 'Shakib Al Hasan', 'Bangladesh', 'All-rounder'),
(15, 'Rashid Khan', 'Afghanistan', 'Bowler');

--coaches
INSERT INTO coaches (Coach_ID, Coach_Name, Experience, Rating) VALUES
(1, 'Rahul Dravid', 10, 4.8),
(2, 'Gary Stead', 8, 4.5),
(3, 'Brendon McCullum', 5, 4.7),
(4, 'Andrew McDonald', 6, 4.6),
(5, 'Saqlain Mushtaq', 7, 4.4),
(6, 'Mark Boucher', 9, 4.3),
(7, 'Russell Domingo', 12, 4.2);

--Teams
INSERT INTO teams (Team_ID, Team_Name, Team_Captain, Team_Coach, Win_Rate) VALUES
(1, 'India', 1, 1, 68.50),
(2, 'New Zealand', 4, 2, 62.30),
(3, 'England', 6, 3, 60.80),
(4, 'Australia', 8, 4, 65.40),
(5, 'Pakistan', 10, 5, 58.20),
(6, 'South Africa', 12, 6, 59.70),
(7, 'Bangladesh', 14, 7, 45.30);

--Matches
INSERT INTO matches (Match_ID, Match_Date, Team1, Team2, Venue) VALUES
(1, '2023-06-10', 1, 2, 'Wankhede Stadium, Mumbai'),
(2, '2023-06-15', 3, 4, 'Lords, London'),
(3, '2023-06-20', 5, 6, 'National Stadium, Karachi'),
(4, '2023-06-25', 7, 1, 'Shere Bangla Stadium, Dhaka'),
(5, '2023-07-01', 2, 3, 'Eden Park, Auckland'),
(6, '2023-07-05', 4, 5, 'MCG, Melbourne'),
(7, '2023-07-10', 6, 7, 'Newlands, Cape Town'),
(8, '2023-07-15', 1, 3, 'Eden Gardens, Kolkata'),
(9, '2023-07-20', 2, 4, 'Basin Reserve, Wellington'),
(10, '2023-07-25', 5, 7, 'Gaddafi Stadium, Lahore');

--Results
INSERT INTO results (Match_ID, Winning_Team, Result_Type) VALUES
(1, 1, 'By 45 runs'),
(2, 3, 'By 3 wickets'),
(3, 6, 'By 25 runs'),
(4, 1, 'By 5 wickets'),
(5, 2, 'By 18 runs'),
(6, 4, 'By 6 wickets'),
(7, 6, 'By 72 runs'),
(8, 1, 'By 8 wickets'),
(9, 4, 'By 4 wickets'),
(10, 5, 'By 35 runs');

--Batsman Stats
INSERT INTO batsman (Player_ID, Runs, Fours, Sixes, Centuries, Half_Centuries, Double_Centuries, Innings, Average, Best_Score, Strike_Rate, MOTM) VALUES
(1, 12650, 1200, 230, 43, 64, 1, 265, 59.31, 254, 93.25, 35),
(2, 9825, 950, 280, 29, 52, 0, 240, 48.87, 212, 88.90, 28),
(4, 7580, 820, 85, 24, 33, 0, 190, 54.14, 189, 79.50, 22),
(6, 10285, 1100, 45, 28, 55, 1, 230, 50.17, 226, 75.80, 25),
(8, 8765, 890, 95, 27, 36, 0, 185, 61.37, 239, 73.40, 24),
(10, 4325, 410, 65, 17, 19, 0, 95, 56.82, 158, 89.70, 15),
(12, 5680, 580, 190, 16, 28, 0, 150, 44.37, 178, 95.60, 18),
(14, 4120, 390, 110, 9, 25, 0, 120, 38.50, 134, 85.30, 12);

--Bowler Stats
INSERT INTO bowler (Player_ID, Wickets, Fifers, Economy, Best, Innings, MOTM) VALUES
(3, 285, 8, 3.85, '6/19', 160, 20),
(5, 310, 10, 4.25, '7/34', 175, 22),
(7, 640, 31, 2.85, '7/42', 290, 35),
(9, 215, 7, 3.65, '6/23', 120, 18),
(11, 195, 6, 4.15, '6/35', 110, 15),
(13, 255, 11, 3.95, '7/29', 145, 19),
(14, 280, 9, 4.35, '6/27', 165, 17),
(15, 170, 5, 4.05, '5/18', 95, 12);

--Match1
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, Runs_Conceded, Wickets, Overs, Maidens) VALUES
(1, 1, 120, 140, 12, 3, 0, 0, 0, 0),
(1, 2, 85, 95, 8, 2, 0, 0, 0, 0),
(1, 3, 15, 10, 2, 0, 35, 3, 8.0, 1),
(1, 4, 65, 80, 6, 1, 0, 0, 0, 0),
(1, 5, 10, 15, 1, 0, 48, 2, 9.0, 0);

--Match2
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(2, 6, 95, 120, 10, 0, 0, 0, 0, 0),
(2, 7, 5, 10, 0, 0, 30, 4, 9.0, 2),
(2, 8, 75, 90, 8, 1, 0, 0, 0, 0),
(2, 9, 20, 15, 3, 0, 42, 3, 8.0, 1);

--Match3
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(3, 10, 85, 95, 9, 2, 0, 0, 0, 0),
(3, 11, 10, 8, 1, 0, 38, 2, 7.0, 0),
(3, 12, 110, 115, 12, 3, 0, 0, 0, 0),
(3, 13, 15, 10, 2, 0, 45, 3, 8.0, 1);

--Match4
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(4, 14, 75, 85, 7, 2, 42, 2, 8.0, 0),
(4, 1, 95, 105, 10, 2, 0, 0, 0, 0),
(4, 2, 65, 70, 7, 1, 0, 0, 0, 0),
(4, 3, 10, 8, 1, 0, 30, 3, 7.0, 1);

--Match5
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(5, 4, 88, 100, 9, 1, 0, 0, 0, 0),
(5, 5, 12, 10, 2, 0, 35, 3, 8.0, 1),
(5, 6, 70, 85, 7, 0, 0, 0, 0, 0),
(5, 7, 5, 8, 0, 0, 40, 2, 9.0, 1);

--Match6
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(6, 8, 105, 120, 11, 2, 0, 0, 0, 0),
(6, 9, 15, 12, 2, 0, 32, 4, 8.0, 2),
(6, 10, 75, 90, 8, 1, 0, 0, 0, 0),
(6, 11, 10, 8, 1, 0, 45, 2, 7.0, 0);

--Match7
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(7, 12, 120, 130, 14, 3, 0, 0, 0, 0),
(7, 13, 25, 20, 3, 1, 30, 5, 8.0, 2),
(7, 14, 65, 75, 7, 1, 48, 2, 9.0, 0),
(7, 15, 10, 15, 1, 0, 42, 3, 8.0, 1);

--Match8
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(8, 1, 135, 145, 15, 4, 0, 0, 0, 0),
(8, 2, 95, 100, 10, 3, 0, 0, 0, 0),
(8, 3, 20, 15, 3, 0, 28, 4, 8.0, 2),
(8, 6, 65, 80, 7, 0, 0, 0, 0, 0),
(8, 7, 10, 15, 1, 0, 52, 2, 9.0, 1);

--match9
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(9, 4, 75, 90, 8, 1, 0, 0, 0, 0),
(9, 5, 15, 12, 2, 0, 45, 2, 8.0, 0),
(9, 8, 95, 110, 10, 2, 0, 0, 0, 0),
(9, 9, 25, 20, 3, 1, 35, 3, 7.0, 1);

--match 10
INSERT INTO innings (Match_ID, Player_ID, Runs, Balls_Faced, Fours, Sixes, runs_conceded, wickets, overs, maidens) VALUES
(10, 10, 110, 125, 12, 3, 0, 0, 0, 0),
(10, 11, 15, 10, 2, 0, 32, 3, 7.0, 1),
(10, 14, 75, 85, 8, 2, 45, 2, 8.0, 0),
(10, 15, 5, 8, 0, 0, 38, 2, 6.0, 0);


--insertion done

-- player statistics view
CREATE VIEW player_stats AS
SELECT 
    p.player_ID,
    p.Name,
    p.Country,
    p.Role,
    COALESCE(bat.Runs, 0) AS Total_Runs,
    COALESCE(bat.Fours, 0) AS Fours,
    COALESCE(bat.Sixes, 0) AS Sixes,
    COALESCE(bat.centuries, 0) AS Centuries,
    COALESCE(bat.half_centuries, 0) AS Half_Centuries,
    COALESCE(bat.average, 0) AS Batting_Average,
    COALESCE(bat.strike_rate, 0) AS Strike_Rate,
    COALESCE(bowl.Wickets, 0) AS Total_Wickets,
    COALESCE(bowl.fifers, 0) AS Five_Wicket_Hauls,
    COALESCE(bowl.economy, 0) AS Economy_Rate,
    COALESCE(bowl.best, 'N/A') AS Best_Bowling,
    COALESCE(bat.motm, 0) + COALESCE(bowl.motm, 0) AS Man_Of_The_Match
FROM 
    players p
LEFT JOIN 
    batsman bat ON p.player_ID = bat.Player_ID
LEFT JOIN 
    bowler bowl ON p.player_ID = bowl.Player_ID;

--Match view
-- View for match details with team names
CREATE VIEW match_details AS
SELECT 
    m.Match_ID,
    m.Match_Date,
    t1.team_name AS Team1_Name,
    t2.team_name AS Team2_Name,
    m.Venue,
    r.Result_Type,
    t3.team_name AS Winning_Team
FROM 
    matches m
JOIN 
    teams t1 ON m.Team1 = t1.team_id
JOIN 
    teams t2 ON m.Team2 = t2.team_id
LEFT JOIN 
    results r ON m.Match_ID = r.Match_ID
LEFT JOIN 
    teams t3 ON r.Winning_Team = t3.team_id;


--Player performance view
CREATE VIEW player_match_performance AS
SELECT 
    i.Match_ID,
    m.Match_Date,
    p.player_ID AS Player_ID,
    p.Name AS Player_Name,
    p.Role,
    t1.team_name AS Team1,
    t2.team_name AS Team2,
    i.Runs,
    i.Balls_Faced,
    i.Fours,
    i.Sixes,
    CASE WHEN i.Balls_Faced > 0 THEN ROUND((i.Runs::numeric / i.Balls_Faced) * 100, 2) ELSE 0 END AS Strike_Rate,
    i.wickets,
    i.runs_conceded,
    i.overs,
    i.maidens,
    CASE WHEN i.overs > 0 THEN ROUND(i.runs_conceded::numeric / i.overs, 2) ELSE 0 END AS Economy
FROM 
    innings i
JOIN 
    players p ON i.Player_ID = p.player_ID
JOIN 
    matches m ON i.Match_ID = m.Match_ID
JOIN 
    teams t1 ON m.Team1 = t1.team_id
JOIN 
    teams t2 ON m.Team2 = t2.team_id;

--team performance view
CREATE VIEW team_performance AS
SELECT 
    t.team_id,
    t.team_name,
    p.Name AS Captain,
    c.coach_name AS Coach,
    t.win_rate,
    COUNT(DISTINCT m.Match_ID) AS Total_Matches,
    COUNT(DISTINCT CASE WHEN r.Winning_Team = t.team_id THEN m.Match_ID END) AS Matches_Won,
    ROUND((COUNT(DISTINCT CASE WHEN r.Winning_Team = t.team_id THEN m.Match_ID END)::numeric / 
           NULLIF(COUNT(DISTINCT m.Match_ID), 0)) * 100, 2) AS Win_Percentage
FROM 
    teams t
LEFT JOIN 
    players p ON t.team_captain = p.player_ID
LEFT JOIN 
    coaches c ON t.team_coach = c.coach_id
LEFT JOIN 
    matches m ON t.team_id = m.Team1 OR t.team_id = m.Team2
LEFT JOIN 
    results r ON m.Match_ID = r.Match_ID
GROUP BY 
    t.team_id, t.team_name, p.Name, c.coach_name, t.win_rate;

-- Function to get head-to-head statistics between two teams
CREATE OR REPLACE FUNCTION get_head_to_head(team1_id INTEGER, team2_id INTEGER)
RETURNS TABLE (
    total_matches BIGINT,
    team1_wins BIGINT,
    team2_wins BIGINT,
    no_result BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_matches,
        SUM(CASE WHEN r.Winning_Team = team1_id THEN 1 ELSE 0 END) as team1_wins,
        SUM(CASE WHEN r.Winning_Team = team2_id THEN 1 ELSE 0 END) as team2_wins,
        SUM(CASE WHEN r.Winning_Team IS NULL THEN 1 ELSE 0 END) as no_result
    FROM matches m
    LEFT JOIN results r ON m.Match_ID = r.Match_ID
    WHERE (m.Team1 = team1_id AND m.Team2 = team2_id)
       OR (m.Team1 = team2_id AND m.Team2 = team1_id);
END;
$$ LANGUAGE plpgsql;

-- Function to get player performance against a specific team
CREATE OR REPLACE FUNCTION get_player_vs_team(player_id INTEGER, team_id INTEGER)
RETURNS TABLE (
    matches BIGINT,
    total_runs BIGINT,
    average NUMERIC,
    strike_rate NUMERIC,
    total_wickets BIGINT,
    bowling_average NUMERIC,
    economy NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT i.Match_ID) as matches,
        SUM(i.Runs) as total_runs,
        CASE WHEN COUNT(DISTINCT i.Match_ID) > 0 THEN ROUND(SUM(i.Runs)::numeric / COUNT(DISTINCT i.Match_ID), 2) ELSE 0 END as average,
        CASE WHEN SUM(i.Balls_Faced) > 0 THEN ROUND((SUM(i.Runs)::numeric / SUM(i.Balls_Faced)) * 100, 2) ELSE 0 END as strike_rate,
        SUM(i.wickets) as total_wickets,
        CASE WHEN SUM(i.wickets) > 0 THEN ROUND(SUM(i.runs_conceded)::numeric / SUM(i.wickets), 2) ELSE 0 END as bowling_average,
        CASE WHEN SUM(i.overs) > 0 THEN ROUND(SUM(i.runs_conceded)::numeric / SUM(i.overs), 2) ELSE 0 END as economy
    FROM innings i
    JOIN matches m ON i.Match_ID = m.Match_ID
    WHERE i.Player_ID = player_id
    AND (m.Team1 = team_id OR m.Team2 = team_id);
END;
$$ LANGUAGE plpgsql;

-- Function to get top performers in a match
CREATE OR REPLACE FUNCTION get_match_top_performers(match_id INTEGER)
RETURNS TABLE (
    player_name VARCHAR,
    player_role VARCHAR,
    runs INTEGER,
    wickets INTEGER,
    performance_rating NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.Name as player_name,
        p.Role as player_role,
        i.Runs as runs,
        i.wickets as wickets,
        -- Simple performance rating formula: runs + (wickets * 20)
        (i.Runs + (i.wickets * 20))::numeric as performance_rating
    FROM innings i
    JOIN players p ON i.Player_ID = p.ID
    WHERE i.Match_ID = match_id
    ORDER BY performance_rating DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

-- Function to update player statistics after a match
-- Function to update player statistics after a match
CREATE OR REPLACE FUNCTION update_player_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update batsman stats
    IF NEW.Runs > 0 THEN
        -- Check if player exists in batsman table
        IF EXISTS (SELECT 1 FROM batsman WHERE Player_ID = NEW.Player_ID) THEN
            UPDATE batsman
            SET 
                Runs = Runs + NEW.Runs,
                Fours = Fours + NEW.Fours,
                Sixes = Sixes + NEW.Sixes,
                innings = innings + 1,
                centuries = CASE WHEN NEW.Runs >= 100 THEN centuries + 1 ELSE centuries END,
                half_centuries = CASE WHEN NEW.Runs >= 50 AND NEW.Runs < 100 THEN half_centuries + 1 ELSE half_centuries END,
                double_centuries = CASE WHEN NEW.Runs >= 200 THEN double_centuries + 1 ELSE double_centuries END,
                best_score = CASE WHEN NEW.Runs > best_score OR best_score IS NULL THEN NEW.Runs ELSE best_score END,
                average = (Runs + NEW.Runs)::numeric / (innings + 1),
                strike_rate = CASE WHEN (Balls_Faced + NEW.Balls_Faced) > 0 
                              THEN ((Runs + NEW.Runs)::numeric / (Balls_Faced + NEW.Balls_Faced)) * 100 
                              ELSE strike_rate END
            WHERE Player_ID = NEW.Player_ID;
        ELSE
            -- Insert new record
            INSERT INTO batsman (
                Player_ID, Runs, Fours, Sixes, innings, 
                centuries, half_centuries, double_centuries, 
                best_score, average, strike_rate
            )
            VALUES (
                NEW.Player_ID, NEW.Runs, NEW.Fours, NEW.Sixes, 1,
                CASE WHEN NEW.Runs >= 100 THEN 1 ELSE 0 END,
                CASE WHEN NEW.Runs >= 50 AND NEW.Runs < 100 THEN 1 ELSE 0 END,
                CASE WHEN NEW.Runs >= 200 THEN 1 ELSE 0 END,
                NEW.Runs,
                NEW.Runs,
                CASE WHEN NEW.Balls_Faced > 0 THEN (NEW.Runs::numeric / NEW.Balls_Faced) * 100 ELSE 0 END
            );
        END IF;
    END IF;
    
    -- Update bowler stats
    IF NEW.wickets > 0 THEN
        -- Check if player exists in bowler table
        IF EXISTS (SELECT 1 FROM bowler WHERE Player_ID = NEW.Player_ID) THEN
            UPDATE bowler
            SET 
                Wickets = Wickets + NEW.wickets,
                innings = innings + 1,
                fifers = CASE WHEN NEW.wickets >= 5 THEN fifers + 1 ELSE fifers END,
                economy = CASE WHEN NEW.overs > 0 
                          THEN ((economy * innings) + (NEW.runs_conceded::numeric / NEW.overs)) / (innings + 1)
                          ELSE economy END,
                best = CASE 
                        WHEN NEW.wickets > CAST(SPLIT_PART(best, '/', 1) AS INTEGER) OR best IS NULL
                        THEN NEW.wickets || '/' || NEW.runs_conceded
                        WHEN NEW.wickets = CAST(SPLIT_PART(best, '/', 1) AS INTEGER) AND 
                             NEW.runs_conceded < CAST(SPLIT_PART(best, '/', 2) AS INTEGER)
                        THEN NEW.wickets || '/' || NEW.runs_conceded
                        ELSE best
                       END
            WHERE Player_ID = NEW.Player_ID;
        ELSE
            -- Insert new record
            INSERT INTO bowler (
                Player_ID, Wickets, innings, fifers, economy, best
            )
            VALUES (
                NEW.Player_ID, NEW.wickets, 1,
                CASE WHEN NEW.wickets >= 5 THEN 1 ELSE 0 END,
                CASE WHEN NEW.overs > 0 THEN NEW.runs_conceded::numeric / NEW.overs ELSE 0 END,
                NEW.wickets || '/' || NEW.runs_conceded
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating player stats after innings insertion
CREATE TRIGGER update_stats_after_innings
AFTER INSERT ON innings
FOR EACH ROW
EXECUTE FUNCTION update_player_stats();

create database cricket_db;