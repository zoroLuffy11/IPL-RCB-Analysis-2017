-- Before I start answering the questions, I checked if there 
-- are any duplicate values or not

-- checked if duplicate match_id is there
select 
Match_Id,count(*)
from matches
group by 1
having count(*) > 1

-- Check duplicate players
select Player_Name, count(*) 
from player
group by Player_Name
having count(*) > 1;

-- Check NULLs in Player DOB
SELECT COUNT(*) FROM Player WHERE DOB IS NULL;

-- Check for NULL bowling skills
SELECT COUNT(*) FROM Player WHERE Bowling_skill IS NULL;

-- Check team name consistency
SELECT DISTINCT Team_Name FROM Team;


-- OBJECTIVE QUESTIONS

-- Q1 : Different Data types of columns in table ball_by_ball
select column_name, data_type
from information_schema.columns
where table_schema = 'ipl' and table_name = 'ball_by_ball'

-- Q2 : What is the total number of runs scored in 1st season by RCB 
use ipl
select 
sum(b.Runs_Scored) as Runs_RCB,
coalesce(sum(er.Extra_Runs),0) as Extra_runs,
(sum(b.Runs_Scored) + coalesce(sum(er.Extra_Runs),0)) as Total_runs_RCB
from ball_by_ball b 
join matches m 
on b.Match_id = m.Match_id
join team t 
on t.Team_Id = b.Team_Batting
left join extra_runs er
on er.Match_id = b.Match_id
and er.Over_id = b.Over_id
and er.Ball_id = b.Ball_id
and er.Innings_NO = b.Innings_No
where t.Team_Name = 'Royal Challengers Bangalore'
and m.Season_Id = 6

-- Q3 : How many players were more than the age of 25 during season 2014?

select 
count(distinct p.Player_Id) as Total_players
from player p 
join player_match pm
on p.Player_id = pm.Player_id
join matches m 
on pm.Match_Id = m.Match_Id
join season s 
on s.Season_Id = m.Season_Id
where timestampdiff(year,DOB,m.Match_Date) > 25 
and s.Season_Year = 2014

-- 25+ of only RCB players

select 
count(distinct p.Player_Id) as Total_players
from player p 
join player_match pm
on p.Player_id = pm.Player_id
join matches m 
on pm.Match_Id = m.Match_Id
join season s 
on s.Season_Id = m.Season_Id
join team t on t.Team_id = pm.Team_id
where timestampdiff(year,DOB,m.Match_Date) > 25 
and s.Season_Year = 2014 and t.Team_Name = 'Royal Challengers Bangalore'

-- Q4 : How many matches did RCB win in 2013? 

select 
count(*) as RCB_Wins_2013
from matches m 
join team t 
on m.Match_Winner = t.Team_id
join Season s 
on s.Season_id = m.Season_id
where s.Season_Year = 2013
and t.Team_Name = 'Royal Challengers Bangalore'

-- Q5 : List the top 10 players according to their strike rate in the last 4 seasons

select 
p.Player_Name,
count(*) as total_balls_played,
sum(b.Runs_Scored) as total_runs,
round(100*sum(b.Runs_Scored)/count(*),2) as Strike_rate
from player p 
join ball_by_ball b 
on b.Striker = p.Player_Id
join matches m 
on b.Match_Id = m.Match_Id
join season s 
on s.Season_Id = m.Season_Id
where s.Season_Year >= (select max(Season_Year) - 3)
and b.Innings_No in (1,2)
group by 1
having count(*)>=100
order by Strike_rate desc
limit 10

-- Q:6 What are the average runs scored by each batsman considering all the seasons?

select 
p.Player_Id,
p.Player_Name,
count(distinct m.Match_Id) as total_matches_played,
sum(b.Runs_Scored) as total_runs_scored,
round(sum(b.Runs_Scored)/count(distinct m.Match_Id),2) as avg_runs
from ball_by_ball b 
join matches m 
on b.Match_Id = m.Match_Id
join player p 
on p.Player_Id = b.Striker
group by 1,2
order by avg_runs desc

-- Q7.What are the average wickets taken by each bowler considering all the seasons?

select 
p.Player_Name,
count(distinct w.Match_Id) as Matches_Bowled,
count(w.Player_Out) as total_wickets,
round(count(w.Player_Out)/count(distinct w.Match_Id),2) as avg_wickets_taken
from wicket_taken w 
join ball_by_ball b
on w.Match_Id = b.Match_Id
and w.Over_Id = b.Over_Id
and w.Ball_Id = b.Ball_Id
and w.Innings_No = b.Innings_No
join player p 
on p.Player_Id = b.Bowler
group by 1
order by avg_wickets_taken desc

-- Q8.List all the players who have average runs scored greater than 
-- the overall average and who have taken wickets greater than the overall average

with batting_stats as (
	select 
    Striker as Player_Id,
    count(distinct Match_Id) as matches_played,
    sum(Runs_Scored) as total_runs,
    round(sum(Runs_Scored)/count(distinct Match_Id),2) as avg_runs
    from ball_by_ball
    group by 1
),
bowling_stats as (
	select 
    Bowler as Player_Id,
    count(distinct w.Match_Id) as total_bowled,
    count(Player_Out) as total_wickets,
    round(count(Player_Out)/count(distinct w.Match_Id),2) as avg_wickets
    from ball_by_ball b
    join wicket_taken w 
    on b.Match_Id = w.Match_Id
    and b.Over_Id = w.Over_Id
    and b.Ball_Id = w.Ball_Id
    and b.Innings_No = w.Innings_No
    group by b.Bowler
)
select 
p.Player_Name,
avg_runs,
avg_wickets
from batting_stats bat
join bowling_stats bowl
on bat.Player_Id = bowl.Player_Id
join player p 
on bat.Player_Id = p.Player_Id
where avg_runs> (select avg(avg_runs) from batting_stats)
and avg_wickets > (select avg(avg_wickets) from bowling_stats)
order by avg_runs desc,avg_wickets desc

-- Q9: Create a table rcb_record table that shows the wins and losses of RCB in an individual venue.

drop table if exists rcb_record;

create table rcb_record as 
	select 
    v.Venue_Name,
    count(distinct m.Match_Id) as total_matches,
    sum(case when m.Match_Winner = 2 then 1 else 0 end) as wins,
    sum(case when m.Match_Winner <> 2 then 1 else 0 end) as losses,
    sum(case when m.Match_Winner is null then 1 else 0 end) as No_Result,
    round(100*sum(case when m.Match_Winner = 2 then 1 else 0 end)/count(distinct m.Match_Id),2)
    as win_percentage
    from matches m 
    join venue v
    on m.Venue_Id = v.Venue_Id
    where m.Team_1 = 2 or m.Team_2 = 2
    group by 1
    order by wins desc

select * from rcb_record

-- Q:10 What is the impact of bowling style on wickets taken?

select 
bs.Bowling_skill,
count(distinct b.Bowler) as Total_Bowlers,
count(w.Player_Out) as Total_Wickets,
count(distinct w.Match_Id) as Total_Matches,
round(count(w.Player_Out) / count(distinct w.Match_Id), 2) as Avg_Wickets_Per_Match
from ball_by_ball b
join wicket_taken w 
on w.Match_Id = b.Match_Id
and w.Over_Id = b.Over_Id
and w.Ball_Id = b.Ball_Id
and w.Innings_No = b.Innings_No
join player p on b.Bowler = p.Player_Id
join bowling_style bs on p.Bowling_skill = bs.Bowling_Id
group by bs.Bowling_skill
order by Total_Wickets desc;


-- Q:11.Write the SQL query to provide a status of whether the 
-- performance of the team is better than the previous year's 
-- performance on the basis of the number of runs scored by the 
-- team in the season and the number of wickets taken 

with t1 as (
	select 
	t.Team_Name,
	s.Season_Year,
	sum(b.Runs_Scored) as Total_runs,
	count(w.Player_Out) as Total_Wickets,
	lag(sum(b.Runs_Scored)) over(partition by t.Team_Name order by s.Season_Year) as Prev_year_runs,
	lag(count(w.Player_Out)) over(partition by t.Team_Name order by s.Season_Year) as Prev_year_wickets
	from ball_by_ball b 
	join matches m 
	on b.Match_Id = m.Match_Id
	join team t 
	on t.Team_Id = b.Team_Batting
	join season s 
	on s.Season_Id = m.Season_Id
	left join wicket_taken w 
	on w.Match_Id = b.Match_Id
	and w.Over_Id = b.Over_Id
	and w.Ball_Id = b.Ball_Id
	and w.Innings_No = b.Innings_No
	group by 1,2
	order by Team_Name,Season_Year
)
select *,
case 
	when Total_runs > Prev_year_runs then 'Better'
    when Total_runs < Prev_year_runs then 'Worse'
    else 'Same'
end as Runs_Status,
case
	when Total_Wickets > Prev_year_wickets then 'Better'
    when Total_Wickets < Prev_year_wickets then 'Worse'
    else 'Same'
end as Wickets_status
from t1

-- Q:12.Can you derive more KPIs for the team strategy?

-- KPI 1: Powerplay run rate per team (overs 1-6)
select
Team_Name,
round(sum(b.Runs_Scored)*6/count(*),2) as Powerplay_run_rate
from ball_by_ball b 
join team t 
on b.Team_Batting = t.Team_Id
where b.Over_Id between 1 and 6
group by 1
order by Powerplay_run_rate desc

-- KPI 2: Death over run rate per team (overs 16-20)
select 
Team_Name,
sum(b.Runs_Scored) AS Total_Runs,
count(*) AS Total_Balls,
round(sum(b.Runs_Scored) * 6.0 / count(*), 2) AS Death_Over_Run_Rate
from ball_by_ball b
join team t on b.Team_Batting = t.Team_Id
where b.Over_Id between 16 and 20
group by t.Team_Name
order by Death_Over_Run_Rate desc;

-- KPI 3: Economy rate per bowler
select p.Player_Name,
round(sum(b.Runs_Scored) * 6.0 / count(*), 2) AS Economy_Rate,
count(distinct b.Match_Id) as Matches
from ball_by_ball b
join player p on b.Bowler = p.Player_Id
group by p.Player_Id, p.Player_Name
having Matches >= 10
order by Economy_Rate ASC
limit 10;

-- KPI 4: Dot ball percentage per bowler
select p.Player_Name,
count(*) AS Total_Balls,
sum(case when b.Runs_Scored = 0 then 1 else 0 end) as Dot_Balls,
round(sum(case when b.Runs_Scored = 0 then 1 else 0 end) * 100.0 / count(*), 2) AS Dot_Ball_Percentage
from ball_by_ball b
join player p on b.Bowler = p.Player_Id
group by p.Player_Id, p.Player_Name
having Total_Balls >= 200
order by Dot_Ball_Percentage desc
limit 10;

-- KPI 5: Boundary percentage per batsman
select 
p.Player_Name,
count(*) as Total_Balls,
sum(case when b.Runs_Scored = 4 then 1 else 0 end) as Fours,
sum(case when b.Runs_Scored = 6 then 1 else 0 end) as Sixes,
round(sum(case when b.Runs_Scored in (4,6) then 1 else 0 end) * 100.0 / count(*),
2) as Boundary_Percentage
from ball_by_ball b
join player p on b.Striker = p.Player_Id
group by p.Player_Id, p.Player_Name
having count(*) >= 200
order by Boundary_Percentage desc
limit 10;


-- Q:13.Using SQL, write a query to find out the average wickets taken by each bowler in each venue. Also, rank the gender according to the average value.

-- Q13: Average wickets per bowler per venue + rank
select 
p.Player_Name,
v.Venue_Name,
count(wt.Player_Out) as Total_Wickets,
count(distinct wt.Match_Id) as Matches,
round(count(wt.Player_Out) / count(distinct wt.Match_Id), 2) as Avg_Wickets,
dense_rank() over(order by count(wt.Player_Out) / count(distinct wt.Match_Id) desc
) as Bowler_Rank
from wicket_taken wt
join ball_by_ball b 
on wt.Match_Id = b.Match_Id 
and wt.Over_Id = b.Over_Id 
and wt.Ball_Id = b.Ball_Id 
and wt.Innings_No = b.Innings_No
join player p on b.Bowler = p.Player_Id
join matches m on wt.Match_Id = m.Match_Id
join venue v on m.Venue_Id = v.Venue_Id
group by p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
having count(distinct wt.Match_Id) >= 2
order by Bowler_Rank;

-- Q:14.Which of the given players have consistently performed well in past seasons? 

select 
Player_Name,
count(distinct Season_Year) as Seasons_Played,
sum(Season_Runs) as Total_Runs,
round(sum(Season_Runs) / count(distinct Season_Year), 2) as Avg_Runs_Per_Season,
min(Season_Runs) as Min_Season_Runs,
max(Season_Runs) as Max_Season_Runs
from (
    select 
	p.Player_Name,
	p.Player_Id,
	s.Season_Year,
	sum(b.Runs_Scored) as Season_Runs
    from ball_by_ball b
    join player p on b.Striker = p.Player_Id
    join matches m on b.Match_Id = m.Match_Id
    join season s on m.Season_Id = s.Season_Id
    group by p.Player_Id, p.Player_Name, s.Season_Year
) as season_totals
group by Player_Id, Player_Name
having count(distinct Season_Year) >= 4
order by Avg_Runs_Per_Season desc
limit 15;

-- Q:15.Are there players whose performance is more suited to specific venues or conditions? 

select 
p.Player_Name,
v.Venue_Name,
count(distinct b.Match_Id) as Matches,
sum(b.Runs_Scored) as Total_Runs,
round(sum(b.Runs_Scored) / count(distinct b.Match_Id), 2) as Avg_Runs,
round(sum(b.Runs_Scored) * 100.0 / count(*), 2) as Strike_Rate
from ball_by_ball b
join player p on b.Striker = p.Player_Id
join matches m on b.Match_Id = m.Match_Id
join venue v on m.Venue_Id = v.Venue_Id
group by p.Player_Id, p.Player_Name, v.Venue_Id, v.Venue_Name
having count(distinct b.Match_Id) >= 3
order by Player_Name,Avg_Runs desc
limit 20;



-- SUBJECTIVE QUESTIONS

-- Q1: Toss decision impact
select 
td.Toss_Name,
count(*) as Total_Matches,
sum(case when m.Toss_Winner = m.Match_Winner then 1 else 0 end) as Won_After_Toss,
round(sum(case when m.Toss_Winner = m.Match_Winner then 1 else 0 end) * 100.0 / count(*), 2) as Win_Percentage
from matches m
join toss_decision td on m.Toss_Decide = td.Toss_Id
group by td.Toss_Name;

-- Venue specific toss analysis:
use ipl
select 
v.Venue_Name,
td.Toss_Name,
count(*) as Total_Matches,
sum(case when m.Toss_Winner = m.Match_Winner then 1 else 0 end) as Wins,
round(sum(case when m.Toss_Winner = m.Match_Winner then 1 else 0 end) * 100.0 / 
count(*), 2) as Win_Pct
from matches m
join toss_decision td on m.Toss_Decide = td.Toss_Id
join venue v on m.Venue_Id = v.Venue_Id
group by v.Venue_Name, td.Toss_Name
having count(*) >= 3
order by Venue_Name,Win_Pct desc;

-- Q2:Suggest some of the players who would be best fit for the team.
select 
p.Player_Name,
round(sum(b.Runs_Scored) / count(distinct m.Match_Id), 2) as Avg_Runs,
round(sum(b.Runs_Scored) * 100.0 / count(*), 2) as Strike_Rate,
count(distinct s.Season_Year) as Seasons_Active,
round((sum(b.Runs_Scored) / count(distinct m.Match_Id)) * 
(sum(b.Runs_Scored) * 100.0 / count(*)) / 100, 2) as Composite_Score
from ball_by_ball b
join player p on b.Striker = p.Player_Id
join matches m on b.Match_Id = m.Match_Id
join season s on m.Season_Id = s.Season_Id
group by p.Player_Id, p.Player_Name
having count(distinct m.Match_Id) >= 20
order by Composite_Score desc
limit 15;


-- Q4: Versatile players who both bat and bowl
with batting as (
    select 
	b.Striker as Player_Id,
	sum(b.Runs_Scored) as Total_Runs,
	round(sum(b.Runs_Scored) * 100.0 / count(*), 2) as Strike_Rate,
	count(distinct b.Match_Id) as Matches_Batted
    from ball_by_ball b
    group by b.Striker
),
bowling as (
    select 
	b.Bowler as Player_Id,
	count(wt.Player_Out) as Total_Wickets,
	round(sum(b.Runs_Scored) * 6.0 / count(*), 2) as Economy_Rate,
	count(distinct b.Match_Id) as Matches_Bowled
    from ball_by_ball b
    left join wicket_taken wt 
	on wt.Match_Id = b.Match_Id
	and wt.Over_Id = b.Over_Id
	and wt.Ball_Id = b.Ball_Id
	and wt.Innings_No = b.Innings_No
    group by b.Bowler
)
select 
p.Player_Name,
bat.Total_Runs,
bat.Strike_Rate,
bowl.Total_Wickets,
bowl.Economy_Rate,
bat.Matches_Batted,
bowl.Matches_Bowled
from batting bat
join bowling bowl on bat.Player_Id = bowl.Player_Id
join player p on bat.Player_Id = p.Player_Id
where bat.Total_Runs > 200 
and bowl.Total_Wickets > 10
order by bat.Total_Runs desc;



-- Q5 Man of the match analysis
select 
p.Player_Name,
count(*) as MOTM_Awards,
count(distinct m.Season_Id) as Seasons
from matches m
join player p on m.Man_of_the_Match = p.Player_Id
group by p.Player_Id, p.Player_Name
order by MOTM_Awards desc
limit 15;

-- Q5 Players who won MOTM for RCB specifically
select 
p.Player_Name,
count(*) as MOTM_Awards,
count(distinct m.Season_Id) as Seasons
from matches m
join player p on m.Man_of_the_Match = p.Player_Id
join player_match pm on p.Player_Id = pm.Player_Id 
and m.Match_Id = pm.Match_Id
where pm.Team_Id = 2
group by p.Player_Id, p.Player_Name
order by MOTM_Awards desc
limit 10;

-- Q7:What do you think could be the factors contributing to the high-scoring matches and the impact on viewership and team strategies
with match_runs as (
select 
b.Match_Id,
sum(b.Runs_Scored) as Total_Runs,
count(distinct b.Over_Id) as Total_Overs
from ball_by_ball b
group by b.Match_Id
),
--  Classified matches as high scoring or normal
match_classification as (
select 
Match_Id,
Total_Runs,
case when Total_Runs > (select avg(Total_Runs) from match_runs) 
	then 'High Scoring' 
	else 'Normal' end as Match_Type
from match_runs
)
--  Analyzed factors
select 
mc.Match_Type,
count(*) as Total_Matches,
round(avg(mc.Total_Runs), 2) as Avg_Runs,
v.Venue_Name,
td.Toss_Name as Toss_Decision,
s.Season_Year
from match_classification mc
join matches m on mc.Match_Id = m.Match_Id
join venue v on m.Venue_Id = v.Venue_Id
join toss_decision td on m.Toss_Decide = td.Toss_Id
join season s on m.Season_Id = s.Season_Id
group by mc.Match_Type, v.Venue_Name, td.Toss_Name, s.Season_Year
order by Venue_Name,mc.Match_Type, Avg_Runs desc;

-- This now shows factors like:
-- Which venues produce high scoring matches
-- Which toss decision leads to high scores
-- Which seasons had more high scoring matches

-- Some additional factors for high scoring matches are
-- Factor 1: Venue wise average runs (pitch factor)
select 
v.Venue_Name,
round(avg(match_runs), 2) as Avg_Match_Runs,
count(*) as Total_Matches
from (
select b.Match_Id, m.Venue_Id, sum(b.Runs_Scored) as match_runs
from ball_by_ball b
join matches m on b.Match_Id = m.Match_Id
group by b.Match_Id, m.Venue_Id
) as venue_runs
join venue v on venue_runs.Venue_Id = v.Venue_Id
group by v.Venue_Name
having count(*) >= 3
order by Avg_Match_Runs desc;

-- Factor 2: Powerplay runs correlation with match total
select 
b.Match_Id,
sum(case when b.Over_Id between 1 and 6 
then b.Runs_Scored else 0 end) as Powerplay_Runs,
sum(case when b.Over_Id between 16 and 20 
then b.Runs_Scored else 0 end) as Death_Runs,
sum(b.Runs_Scored) as Total_Runs
from ball_by_ball b
group by b.Match_Id
order by Total_Runs desc
limit 20;



-- Q:8.Analyze the impact of home-ground advantage on team performance and identify strategies to maximize this advantage for RCB.

-- RCB home vs away performance
select 
case when v.Venue_Name = 'M Chinnaswamy Stadium' 
 then 'Home' else 'Away' end as Ground_Type,
count(*) as Total_Matches,
sum(case when m.Match_Winner = 2 then 1 else 0 end) as Wins,
round(sum(case when m.Match_Winner = 2 then 1 else 0 end) * 100.0 / count(*), 2) as Win_Pct
from matches m
join venue v on m.Venue_Id = v.Venue_Id
where m.Team_1 = 2 or m.Team_2 = 2
group by Ground_Type;

-- Chinnaswamy stadium specific player performance (home ground)
select 
p.Player_Name,
count(distinct b.Match_Id) as Matches,
sum(b.Runs_Scored) as Total_Runs,
round(sum(b.Runs_Scored) / count(distinct b.Match_Id), 2) as Avg_Runs,
round(sum(b.Runs_Scored) * 100.0 / count(*), 2) as Strike_Rate
from ball_by_ball b
join player p on b.Striker = p.Player_Id
join matches m on b.Match_Id = m.Match_Id
join venue v on m.Venue_Id = v.Venue_Id
where v.Venue_Name = 'M Chinnaswamy Stadium'
and b.Team_Batting = 2
group by p.Player_Id, p.Player_Name
having count(distinct b.Match_Id) >= 3
order by Avg_Runs desc;

-- Q9.Come up with a visual and analytical analysis of the RCB's past season's performance and potential reasons for them not winning a trophy.

--  RCB season wise runs and wickets
select 
s.Season_Year,
sum(b.Runs_Scored) as Total_Runs,
count(wt.Player_Out) as Total_Wickets,
count(distinct m.Match_Id) as Matches_Played
from ball_by_ball b
join matches m on b.Match_Id = m.Match_Id
join season s on m.Season_Id = s.Season_Id
left join wicket_taken wt 
on wt.Match_Id = b.Match_Id
and wt.Over_Id = b.Over_Id
and wt.Ball_Id = b.Ball_Id
and wt.Innings_No = b.Innings_No
where b.Team_Batting = 2
group by s.Season_Year
order by s.Season_Year;

-- S9b: RCB win percentage per season
select 
s.Season_Year,
count(distinct m.Match_Id) as Matches,
sum(case when m.Match_Winner = 2 then 1 else 0 end) as Wins,
round(sum(case when m.Match_Winner = 2 then 1 else 0 end) * 100.0 / 
count(distinct m.Match_Id), 2) as Win_Pct
from matches m
join season s on m.Season_Id = s.Season_Id
where m.Team_1 = 2 or m.Team_2 = 2
group by s.Season_Year
order by s.Season_Year;

