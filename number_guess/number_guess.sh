#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~ Guess the Number Game ~~~~\n"

GET_USERNAME(){
echo "Enter your username:"
read USERNAME_INPUT
}

GET_USER() {
  USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_INPUT'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'") 
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
}

INSERT_USER() {
  if [[ -z $USERNAME ]]
then  
  USERNAME_INSERT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME_INPUT', 0)")
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi 
}

GET_SECRET_NUMBER() {
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
}

GUESS_FUNCT(){
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  read GUESS
  let NUMBER_OF_GUESSES++
 
  if [[ $GUESS != [0-9]* ]]
  then
    GUESS_FUNCT "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    GUESS_FUNCT "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    GUESS_FUNCT "It's lower than that, guess again:"
  fi
}

CORRECT_GUESS() {

GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
GAMES_PLAYED_INSERT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME_INPUT'")

if [[ -z $BEST_GAME ]]
then
  SET_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME_INPUT'")
elif [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  NEW_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME_INPUT'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

exit 0

}

GET_USERNAME

GET_USER

INSERT_USER

GET_SECRET_NUMBER

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  GUESS_FUNCT
done

CORRECT_GUESS