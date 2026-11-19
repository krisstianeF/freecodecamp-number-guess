#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Enter your username:"
read USERNAME

SAFE_NAME=${USERNAME//\'/\'\'}

USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$SAFE_NAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$SAFE_NAME')" > /dev/null
else
  IFS="|" read NAME GAMES BEST <<< "$USER_INFO"
  echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
    read GUESS
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
    read GUESS
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$SAFE_NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$SAFE_NAME'")

NEW_GAMES=$((GAMES_PLAYED + 1))

if [[ -z $BEST_GAME ]]
then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$NUMBER_OF_GUESSES WHERE username='$SAFE_NAME'" > /dev/null
elif (( NUMBER_OF_GUESSES < BEST_GAME ))
then
  $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$NUMBER_OF_GUESSES WHERE username='$SAFE_NAME'" > /dev/null
else
  $PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE username='$SAFE_NAME'" > /dev/null
fi