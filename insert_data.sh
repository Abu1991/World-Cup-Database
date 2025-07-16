#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
clear

TRUNCATE=$($PSQL "TRUNCATE table teams, games")

while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  ROW=$($PSQL "SELECT * FROM teams WHERE name='$winner';")

  readarray -d "|" -t strarr <<< "$ROW"

  if (( ${strarr[0]} ))
  then
    echo "Team already exists."
  else
    WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$winner');")
  fi

  ROW=$($PSQL "SELECT * FROM teams WHERE name='$opponent';")

  readarray -d "|" -t strarr <<< "$ROW"

  if (( ${strarr[0]} ))
  then
    echo "Team already exists."
  else
    OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$opponent');")
  fi

  WINNER=$($PSQL "SELECT * FROM teams WHERE name='$winner';")
  OPPONENT=$($PSQL "SELECT * FROM teams WHERE name='$opponent';")
  readarray -d "|" -t winnerarr <<< "$WINNER"
  readarray -d "|" -t opponentarr <<< "$OPPONENT"

  GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', ${winnerarr[0]}, ${opponentarr[0]}, $winner_goals, $opponent_goals);")
done < <(tail -n 32 games.csv)
