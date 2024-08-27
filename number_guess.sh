#!/bin/bash

#add psql database 
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#cereate secret_number
SECRET_NUMBER=$(expr 1 + $RANDOM % 1000)

#create variable to count guesses 
NUMBER_OF_GUESSES=1

GUESSING_GAME(){
  #get username
echo "Enter your username:"
read USERNAME

#check if username is in database 
GET_USERNAME=$($PSQL "SELECT username FROM player WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(best_game) FROM player WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(id) FROM player WHERE username = '$USERNAME'")

if [[ $GET_USERNAME ]]
then 
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else 
echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

#take player to game
GAME "\nGuess the secret number between 1 and 1000:"
}

#create game
GAME(){
  ARG=$1
  if [[ $ARG ]]
  then
   echo -e $ARG
  fi
  #ask player for guess
read GUESS 

#check if guess is a interager
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then 
GAME "\nThat is not an integer, guess again:"
fi

#if guess is correct 
if [[ $GUESS = $SECRET_NUMBER ]]
then
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

#check if game is best game
if [[ $BEST_GAME ]]
then
#check if number of guesses is less then best game
if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
then 
BEST_GAME=$NUMBER_OF_GUESSES
fi
else 
BEST_GAME=$NUMBER_OF_GUESSES
fi

#insert player data
INSERT_PLAYER_DATA=$($PSQL "INSERT INTO player(username, best_game) VALUES('$USERNAME', $BEST_GAME)")
fi

#if guess is to high
if [[ $GUESS > $SECRET_NUMBER ]] 
then 
NUMBER_OF_GUESSES=$(expr $NUMBER_OF_GUESSES + 1)
GAME "\nIt's lower than that, guess again:"
fi 

#if guess is to low 
if [[ $GUESS < $SECRET_NUMBER ]] 
then 
NUMBER_OF_GUESSES=$(expr $NUMBER_OF_GUESSES + 1)
GAME "\nIt's higher than that, guess again:"
fi

}

GUESSING_GAME 
