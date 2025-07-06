import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import psycopg2
import plotly.express as px
from sqlalchemy import create_engine

# Set page configuration
st.set_page_config(
    page_title="Cricket Analytics Dashboard",
    page_icon="🏏",
    layout="wide"
)

# Database connection function
def get_connection():
    try:
        # Replace these with your actual database credentials
        conn = psycopg2.connect(
            host="localhost",
            database="postgres",
            user="postgres",
            password="barath@2005"
        )
        return conn
    except Exception as e:
        st.error(f"Database connection error: {e}")
        return None

# Function to execute queries
def run_query(query):
    conn = get_connection()
    if conn:
        try:
            df = pd.read_sql_query(query, conn)
            conn.close()
            return df
        except Exception as e:
            st.error(f"Query execution error: {e}")
            conn.close()
            return None
    return None

# Sidebar for navigation
st.sidebar.title("Cricket Analytics")
page = st.sidebar.selectbox(
    "Select Page", 
    ["Home", "Player Statistics", "Team Analysis", "Match Analysis", "Head to Head"]
)

# Home page
if page == "Home":
    st.title("Cricket Analytics Dashboard 🏏")
    st.write("Welcome to the Cricket Analytics Dashboard. Use the sidebar to navigate through different analytics sections.")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Top Batsmen by Runs")
        query = """
        SELECT p.Name, b.Runs, b.Average, b.Strike_Rate
        FROM players p
        JOIN batsman b ON p.player_ID = b.Player_ID
        ORDER BY b.Runs DESC
        LIMIT 5
        """
        df = run_query(query)
        if df is not None and not df.empty:
            st.dataframe(df)
            
            # Create bar chart
            fig = px.bar(df, x='name', y='runs', title="Top Batsmen by Runs")
            st.plotly_chart(fig)
    
    with col2:
        st.subheader("Top Bowlers by Wickets")
        query = """
        SELECT p.Name, b.Wickets, b.Economy
        FROM players p
        JOIN bowler b ON p.player_ID = b.Player_ID
        ORDER BY b.Wickets DESC
        LIMIT 5
        """
        df = run_query(query)
        if df is not None and not df.empty:
            st.dataframe(df)
            
            # Create bar chart
            fig = px.bar(df, x='name', y='wickets', title="Top Bowlers by Wickets")
            st.plotly_chart(fig)
    
    # Recent matches
    st.subheader("Recent Matches")
    query = """
    SELECT m.Match_ID, m.Match_Date, t1.team_name as Team1, t2.team_name as Team2, 
           r.Result_Type, t3.team_name as Winner
    FROM matches m
    JOIN teams t1 ON m.Team1 = t1.team_id
    JOIN teams t2 ON m.Team2 = t2.team_id
    LEFT JOIN results r ON m.Match_ID = r.Match_ID
    LEFT JOIN teams t3 ON r.Winning_Team = t3.team_id
    ORDER BY m.Match_Date DESC
    LIMIT 5
    """
    df = run_query(query)
    if df is not None and not df.empty:
        st.dataframe(df)

# Player Statistics page
elif page == "Player Statistics":
    st.title("Player Statistics")
    
    # Player selection
    query = "SELECT player_ID, Name FROM players ORDER BY Name"
    players_df = run_query(query)
    
    if players_df is not None and not players_df.empty:
        player_id = st.selectbox("Select Player", players_df['player_id'].tolist(), 
                                format_func=lambda x: players_df[players_df['player_id'] == x]['name'].iloc[0])
        
        tab1, tab2 = st.tabs(["Batting", "Bowling"])
        
        with tab1:
            st.subheader("Batting Statistics")
            query = f"""
            SELECT p.Name, b.Runs, b.Fours, b.Sixes, b.Centuries, b.Half_Centuries, 
                   b.Double_Centuries, b.Innings, b.Average, b.Best_Score, b.Strike_Rate, b.MOTM
            FROM players p
            LEFT JOIN batsman b ON p.player_ID = b.Player_ID
            WHERE p.player_ID = {player_id}
            """
            batting_df = run_query(query)
            
            if batting_df is not None and not batting_df.empty:
                # Display basic stats
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Runs", batting_df['runs'].iloc[0] if 'runs' in batting_df and not pd.isna(batting_df['runs'].iloc[0]) else 0)
                with col2:
                    st.metric("Average", round(batting_df['average'].iloc[0], 2) if 'average' in batting_df and not pd.isna(batting_df['average'].iloc[0]) else 0)
                with col3:
                    st.metric("Strike Rate", round(batting_df['strike_rate'].iloc[0], 2) if 'strike_rate' in batting_df and not pd.isna(batting_df['strike_rate'].iloc[0]) else 0)
                with col4:
                    st.metric("Best Score", batting_df['best_score'].iloc[0] if 'best_score' in batting_df and not pd.isna(batting_df['best_score'].iloc[0]) else 0)
                
                # Display detailed stats
                st.subheader("Detailed Batting Statistics")
                st.dataframe(batting_df)
                
                # Get innings data for the player
                query = f"""
                SELECT m.Match_Date, t1.team_name as Team1, t2.team_name as Team2, 
                       i.Runs, i.Balls_Faced, i.Fours, i.Sixes
                FROM innings i
                JOIN matches m ON i.Match_ID = m.Match_ID
                JOIN teams t1 ON m.Team1 = t1.team_id
                JOIN teams t2 ON m.Team2 = t2.team_id
                WHERE i.Player_ID = {player_id}
                ORDER BY m.Match_Date DESC
                LIMIT 10
                """
                innings_df = run_query(query)
                
                if innings_df is not None and not innings_df.empty:
                    st.subheader("Recent Batting Performances")
                    st.dataframe(innings_df)
                    
                    # Create line chart for runs in recent matches
                    fig = px.line(innings_df, x='match_date', y='runs', 
                                 title=f"Runs in Recent Matches - {batting_df['name'].iloc[0]}")
                    st.plotly_chart(fig)
                    
                    # Create pie chart for runs distribution
                    if 'runs' in batting_df and 'fours' in batting_df and 'sixes' in batting_df:
                        runs = batting_df['runs'].iloc[0] if not pd.isna(batting_df['runs'].iloc[0]) else 0
                        fours = batting_df['fours'].iloc[0] if not pd.isna(batting_df['fours'].iloc[0]) else 0
                        sixes = batting_df['sixes'].iloc[0] if not pd.isna(batting_df['sixes'].iloc[0]) else 0
                        
                        # Calculate runs from boundaries and singles/doubles
                        runs_from_fours = fours * 4
                        runs_from_sixes = sixes * 6
                        other_runs = runs - runs_from_fours - runs_from_sixes
                        
                        data = {
                            'Category': ['Singles/Doubles/Threes', 'Fours', 'Sixes'],
                            'Runs': [other_runs, runs_from_fours, runs_from_sixes]
                        }
                        pie_df = pd.DataFrame(data)
                        fig = px.pie(pie_df, values='Runs', names='Category', 
                                    title=f"Runs Distribution - {batting_df['name'].iloc[0]}")
                        st.plotly_chart(fig)
        
        with tab2:
            st.subheader("Bowling Statistics")
            query = f"""
            SELECT p.Name, b.Wickets, b.Fifers, b.Economy, b.Best, b.Innings, b.MOTM
            FROM players p
            LEFT JOIN bowler b ON p.player_ID = b.Player_ID
            WHERE p.player_ID = {player_id}
            """
            bowling_df = run_query(query)
            
            if bowling_df is not None and not bowling_df.empty:
                # Display basic stats
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Wickets", bowling_df['wickets'].iloc[0] if 'wickets' in bowling_df and not pd.isna(bowling_df['wickets'].iloc[0]) else 0)
                with col2:
                    st.metric("Economy", round(bowling_df['economy'].iloc[0], 2) if 'economy' in bowling_df and not pd.isna(bowling_df['economy'].iloc[0]) else 0)
                with col3:
                    st.metric("5 Wicket Hauls", bowling_df['fifers'].iloc[0] if 'fifers' in bowling_df and not pd.isna(bowling_df['fifers'].iloc[0]) else 0)
                with col4:
                    st.metric("Best Figures", bowling_df['best'].iloc[0] if 'best' in bowling_df and not pd.isna(bowling_df['best'].iloc[0]) else "N/A")
                
                # Display detailed stats
                st.subheader("Detailed Bowling Statistics")
                st.dataframe(bowling_df)
                
                # Get innings data for the player
                query = f"""
                SELECT m.Match_Date, t1.team_name as Team1, t2.team_name as Team2, 
                       i.Wickets, i.Runs_Conceded, i.Overs, i.Maidens
                FROM innings i
                JOIN matches m ON i.Match_ID = m.Match_ID
                JOIN teams t1 ON m.Team1 = t1.team_id
                JOIN teams t2 ON m.Team2 = t2.team_id
                WHERE i.Player_ID = {player_id}
                ORDER BY m.Match_Date DESC
                LIMIT 10
                """
                innings_df = run_query(query)
                
                if innings_df is not None and not innings_df.empty:
                    st.subheader("Recent Bowling Performances")
                    st.dataframe(innings_df)
                    
                    # Create line chart for wickets in recent matches
                    fig = px.line(innings_df, x='match_date', y='wickets', 
                                 title=f"Wickets in Recent Matches - {bowling_df['name'].iloc[0]}")
                    st.plotly_chart(fig)

# Team Analysis page
elif page == "Team Analysis":
    st.title("Team Analysis")
    
    # Team selection
    query = "SELECT team_id, team_name FROM teams ORDER BY team_name"
    teams_df = run_query(query)
    
    if teams_df is not None and not teams_df.empty:
        team_id = st.selectbox("Select Team", teams_df['team_id'].tolist(), 
                              format_func=lambda x: teams_df[teams_df['team_id'] == x]['team_name'].iloc[0])
        
        # Team overview
        query = f"""
        SELECT t.team_name, t.win_rate, 
               p.Name as Captain, c.coach_name as Coach
        FROM teams t
        LEFT JOIN players p ON t.team_captain = p.player_ID
        LEFT JOIN coaches c ON t.team_coach = c.coach_id
        WHERE t.team_id = {team_id}
        """
        team_info = run_query(query)
        
        if team_info is not None and not team_info.empty:
            st.subheader("Team Overview")
            
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Team", team_info['team_name'].iloc[0])
            with col2:
                st.metric("Captain", team_info['captain'].iloc[0] if not pd.isna(team_info['captain'].iloc[0]) else "N/A")
            with col3:
                st.metric("Coach", team_info['coach'].iloc[0] if not pd.isna(team_info['coach'].iloc[0]) else "N/A")
            
            st.metric("Win Rate", f"{team_info['win_rate'].iloc[0]}%" if not pd.isna(team_info['win_rate'].iloc[0]) else "N/A")
            
            # Team players
            st.subheader("Team Players")
            query = f"""
            SELECT p.player_ID, p.Name, p.Role, p.Country,
                   COALESCE(bat.Runs, 0) as Batting_Runs,
                   COALESCE(bowl.Wickets, 0) as Bowling_Wickets
            FROM players p
            LEFT JOIN batsman bat ON p.player_ID = bat.Player_ID
            LEFT JOIN bowler bowl ON p.player_ID = bowl.Player_ID
           WHERE p.Country = (
          SELECT t.team_name 
          FROM teams t 
          WHERE t.team_id = {team_id}
         )
        ORDER BY p.Name
        """
            players_df = run_query(query)
            
            if players_df is not None and not players_df.empty:
                st.dataframe(players_df)
                
                # Create bar chart for player contributions
                fig = px.bar(players_df, x='name', y=['batting_runs', 'bowling_wickets'], 
                            title="Player Contributions", barmode='group')
                st.plotly_chart(fig)
            
            # Team performance
            st.subheader("Recent Match Results")
            query = f"""
            SELECT m.Match_ID, m.Match_Date, 
                   CASE WHEN m.Team1 = {team_id} THEN t2.team_name ELSE t1.team_name END as Opponent,
                   r.Result_Type,
                   CASE WHEN r.Winning_Team = {team_id} THEN 'Won' ELSE 'Lost' END as Result
            FROM matches m
            JOIN teams t1 ON m.Team1 = t1.team_id
            JOIN teams t2 ON m.Team2 = t2.team_id
            LEFT JOIN results r ON m.Match_ID = r.Match_ID
            WHERE m.Team1 = {team_id} OR m.Team2 = {team_id}
            ORDER BY m.Match_Date DESC
            LIMIT 10
            """
            results_df = run_query(query)
            
            if results_df is not None and not results_df.empty:
                st.dataframe(results_df)
                
                # Create win/loss pie chart
                wins = len(results_df[results_df['result'] == 'Won'])
                losses = len(results_df[results_df['result'] == 'Lost'])
                
                data = {
                    'Result': ['Won', 'Lost'],
                    'Count': [wins, losses]
                }
                pie_df = pd.DataFrame(data)
                fig = px.pie(pie_df, values='Count', names='Result', 
                            title=f"Win/Loss Record - Last {len(results_df)} matches")
                st.plotly_chart(fig)

# Match Analysis page
elif page == "Match Analysis":
    st.title("Match Analysis")
    
    # Match selection
    query = """
    SELECT m.Match_ID, m.Match_Date, t1.team_name as Team1, t2.team_name as Team2
    FROM matches m
    JOIN teams t1 ON m.Team1 = t1.team_id
    JOIN teams t2 ON m.Team2 = t2.team_id
    ORDER BY m.Match_Date DESC
    """
    matches_df = run_query(query)
    
    if matches_df is not None and not matches_df.empty:
        match_id = st.selectbox("Select Match", matches_df['match_id'].tolist(), 
                               format_func=lambda x: f"{matches_df[matches_df['match_id'] == x]['team1'].iloc[0]} vs {matches_df[matches_df['match_id'] == x]['team2'].iloc[0]} ({matches_df[matches_df['match_id'] == x]['match_date'].iloc[0]})")
        
        # Match details
        match_info = matches_df[matches_df['match_id'] == match_id]
        
        if not match_info.empty:
            st.subheader("Match Details")
            
            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("Date", str(match_info['match_date'].iloc[0]))
            with col2:
                st.metric("Team 1", match_info['team1'].iloc[0])
            with col3:
                st.metric("Team 2", match_info['team2'].iloc[0])
            
            # Match result
            query = f"""
            SELECT r.Result_Type, t.team_name as Winner
            FROM results r
            LEFT JOIN teams t ON r.Winning_Team = t.team_id
            WHERE r.Match_ID = {match_id}
            """
            result_df = run_query(query)
            
            if result_df is not None and not result_df.empty:
                st.subheader("Match Result")
                st.write(f"**Winner:** {result_df['winner'].iloc[0]}")
                st.write(f"**Result Type:** {result_df['result_type'].iloc[0]}")
            
            # Player performances
            st.subheader("Player Performances")
            query = f"""
            SELECT p.Name, i.Runs, i.Balls_Faced, i.Fours, i.Sixes, 
                   i.Wickets, i.Runs_Conceded, i.Overs, i.Maidens
            FROM innings i
            JOIN players p ON i.Player_ID = p.player_ID
            WHERE i.Match_ID = {match_id}
            ORDER BY i.Runs DESC, i.Wickets DESC
            """
            performances_df = run_query(query)
            
            if performances_df is not None and not performances_df.empty:
                st.dataframe(performances_df)
                
                # Top batsmen
                st.subheader("Top Batsmen")
                batsmen_df = performances_df.sort_values(by='runs', ascending=False).head(5)
                fig = px.bar(batsmen_df, x='name', y='runs', title="Top Run Scorers")
                st.plotly_chart(fig)
                
                # Top bowlers
                st.subheader("Top Bowlers")
                bowlers_df = performances_df.sort_values(by='wickets', ascending=False).head(5)
                fig = px.bar(bowlers_df, x='name', y='wickets', title="Top Wicket Takers")
                st.plotly_chart(fig)

# Head to Head page
elif page == "Head to Head":
    st.title("Head to Head Analysis")
    
    # Team selection
    query = "SELECT team_id, team_name FROM teams ORDER BY team_name"
    teams_df = run_query(query)
    
    if teams_df is not None and not teams_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            team1_id = st.selectbox("Select Team 1", teams_df['team_id'].tolist(), 
                                  format_func=lambda x: teams_df[teams_df['team_id'] == x]['team_name'].iloc[0],
                                  key="team1")
        
        with col2:
            team2_id = st.selectbox("Select Team 2", teams_df['team_id'].tolist(), 
                                  format_func=lambda x: teams_df[teams_df['team_id'] == x]['team_name'].iloc[0],
                                  key="team2")
        
        if team1_id != team2_id:
            team1_name = teams_df[teams_df['team_id'] == team1_id]['team_name'].iloc[0]
            team2_name = teams_df[teams_df['team_id'] == team2_id]['team_name'].iloc[0]
            
            st.subheader(f"{team1_name} vs {team2_name}")
            
            # Head to head record
            query = f"""
            SELECT 
                COUNT(*) as Total_Matches,
                SUM(CASE WHEN r.Winning_Team = {team1_id} THEN 1 ELSE 0 END) as Team1_Wins,
                SUM(CASE WHEN r.Winning_Team = {team2_id} THEN 1 ELSE 0 END) as Team2_Wins,
                SUM(CASE WHEN r.Winning_Team IS NULL THEN 1 ELSE 0 END) as No_Result
            FROM matches m
            LEFT JOIN results r ON m.Match_ID = r.Match_ID
            WHERE (m.Team1 = {team1_id} AND m.Team2 = {team2_id})
               OR (m.Team1 = {team2_id} AND m.Team2 = {team1_id})
            """
            h2h_df = run_query(query)
            
            if h2h_df is not None and not h2h_df.empty:
                total = h2h_df['total_matches'].iloc[0]
                team1_wins = h2h_df['team1_wins'].iloc[0]
                team2_wins = h2h_df['team2_wins'].iloc[0]
                no_result = h2h_df['no_result'].iloc[0]
                
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Total Matches", total)
                with col2:
                    st.metric(f"{team1_name} Wins", team1_wins)
                with col3:
                    st.metric(f"{team2_name} Wins", team2_wins)
                with col4:
                    st.metric("No Result", no_result)
                
                # Create pie chart
                data = {
                    'Result': [f'{team1_name} Wins', f'{team2_name} Wins', 'No Result'],
                    'Count': [team1_wins, team2_wins, no_result]
                }
                pie_df = pd.DataFrame(data)
                fig = px.pie(pie_df, values='Count', names='Result', 
                            title=f"Head to Head: {team1_name} vs {team2_name}")
                st.plotly_chart(fig)
            
            # Match history
            st.subheader("Match History")
            query = f"""
            SELECT m.Match_ID, m.Match_Date, m.Venue,
                   CASE WHEN r.Winning_Team = {team1_id} THEN '{team1_name}'
                        WHEN r.Winning_Team = {team2_id} THEN '{team2_name}'
                        ELSE 'No Result' END as Winner,
                   r.Result_Type
            FROM matches m
            LEFT JOIN results r ON m.Match_ID = r.Match_ID
            WHERE (m.Team1 = {team1_id} AND m.Team2 = {team2_id})
               OR (m.Team1 = {team2_id} AND m.Team2 = {team1_id})
            ORDER BY m.Match_Date DESC
            """
            history_df = run_query(query)
            
            if history_df is not None and not history_df.empty:
                st.dataframe(history_df)
                
                # Create timeline
                fig = px.timeline(history_df, x_start='match_date', x_end='match_date', y='winner',
                                 color='winner', hover_data=['venue', 'result_type'],
                                 title=f"Match Timeline: {team1_name} vs {team2_name}")
                fig.update_yaxes(autorange="reversed")
                st.plotly_chart(fig)
            
            # Player performance in head-to-head
            st.subheader("Top Performers in Head-to-Head")
            
            # Top batsmen
            query = f"""
            SELECT p.Name, p.Role, SUM(i.Runs) as Total_Runs, 
                   AVG(i.Runs) as Avg_Runs, SUM(i.Fours) as Fours, SUM(i.Sixes) as Sixes
            FROM innings i
            JOIN players p ON i.Player_ID = p.player_ID
            JOIN matches m ON i.Match_ID = m.Match_ID
            WHERE i.Match_ID IN (
                SELECT Match_ID FROM matches
                WHERE (Team1 = {team1_id} AND Team2 = {team2_id})
                   OR (Team1 = {team2_id} AND Team2 = {team1_id})
            )
            GROUP BY p.Name, p.Role
            ORDER BY Total_Runs DESC
            LIMIT 5
            """
            batsmen_df = run_query(query)
            
            if batsmen_df is not None and not batsmen_df.empty:
                st.subheader("Top Batsmen")
                st.dataframe(batsmen_df)
                
                fig = px.bar(batsmen_df, x='name', y='total_runs', 
                            title=f"Top Run Scorers in {team1_name} vs {team2_name}")
                st.plotly_chart(fig)
            
            # Top bowlers
            query = f"""
            SELECT p.Name, p.Role, SUM(i.Wickets) as Total_Wickets, 
                   AVG(i.Wickets) as Avg_Wickets, SUM(i.Maidens) as Maidens
            FROM innings i
            JOIN players p ON i.Player_ID = p.player_ID
            JOIN matches m ON i.Match_ID = m.Match_ID
            WHERE i.Match_ID IN (
                SELECT Match_ID FROM matches
                WHERE (Team1 = {team1_id} AND Team2 = {team2_id})
                   OR (Team1 = {team2_id} AND Team2 = {team1_id})
            )
            GROUP BY p.Name, p.Role
            ORDER BY Total_Wickets DESC
            LIMIT 5
            """
            bowlers_df = run_query(query)
            
            if bowlers_df is not None and not bowlers_df.empty:
                st.subheader("Top Bowlers")
                st.dataframe(bowlers_df)
                
                fig = px.bar(bowlers_df, x='name', y='total_wickets', 
                            title=f"Top Wicket Takers in {team1_name} vs {team2_name}")
                st.plotly_chart(fig)
        else:
            st.warning("Please select two different teams for head-to-head analysis.")

# Footer
st.markdown("---")
st.markdown("Cricket Analytics Dashboard | Created with Streamlit")