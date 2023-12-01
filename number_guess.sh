#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( (RANDOM % 1000) + 1))
echo $SECRET_NUMBER

echo -e "\nEnter your username:"
read NAME

USERNAME=$($PSQL "SELECT username FROM games WHERE username='$NAME'")

if [[ -z $USERNAME ]]
then

  # Make username user input
  USERNAME=$NAME

  # OUTPUT: Welcome, <username>! It looks like this is your first time here.
  echo -e "\nWelcome, $(echo $USERNAME | xargs)! It looks like this is your first time here."

else

  # Get games_played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE username='$USERNAME'")
  # Get best_game
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")

  # OUTPUT: Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
  echo -e "\nWelcome back, $(echo $USERNAME | xargs)! You have played $(echo $GAMES_PLAYED | xargs) games, and your best game took $(echo $BEST_GAME | xargs) guesses.\n"

fi

echo -e "\nGuess the secret number between 1 and 1000:"
GUESSES=0

while true
do

  read USER_GUESS

  # if input not number
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  fi

  if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
  then

    ((GUESSES++))
    echo -e "\nIt's higher than that, guess again:"


  else if [[ $USER_GUESS -gt $SECRET_NUMBER ]]
  then

    ((GUESSES++))
    echo -e "\nIt's lower than that, guess again:"

  else

    ((GUESSES++))
    BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE username='$USERNAME'")

    if [[ -z $BEST_GAME ]]
    then

      INSERT_INFO=$($PSQL "INSERT INTO games(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESSES)")
      echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
      exit

    else

      if [[ $GUESSES -lt $BEST_GAME ]]
      then

        ((GAMES_PLAYED++))
        UPDATE_GAME_INFO=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED, best_game=$GUESSES WHERE username='$USERNAME'")

        echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
        exit

      else

        ((GAMES_PLAYED++))
        UPDATE_GAME_INFO=$($PSQL "UPDATE games SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

        echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"
        exit

      fi

    fi

  fi; fi
done
