#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
if [[ $1 ]] ## if argument exists
then
  if [[ $1 == [0-9]* ]] # if the argument is a number
  then 
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT name FROM elements WHERE atomic_number = $1")
    if [[ -z $ATOMIC_NUMBER_RESULT ]] # if the argument is an atomic number in the database
    then # the argument is a number not matching an atomic number in the database
      echo "I could not find that element in the database."; exit 0;
    else 
      ATOMIC_NUMBER=$1
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
      NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    fi  # fi the argument is an atomic number in the database
  else  # the argument is not a number
    SYMBOL_RESULT=$($PSQL "SELECT atomic_number, name FROM elements WHERE symbol = '$1'")
    if [[ -z $SYMBOL_RESULT ]]  # if the argument is a symbol in the database
    then
      NAME_RESULT=$($PSQL "SELECT atomic_number, symbol FROM elements WHERE name = '$1'")
      if [[ -z $NAME_RESULT ]]  # if the argument is a name in the database
      then
        echo "I could not find that element in the database."; exit 0;
      else
        NAME=$1
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME'")
      fi  # fi the argument is a name in the database
    else  
      SYMBOL=$1
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
      NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")
    fi  # fi the argument is a symbol in the database
  fi  # fi the argument is a number
  TYPE=$($PSQL "SELECT type FROM properties FULL JOIN types ON properties.type_id = types.type_id WHERE atomic_number = $ATOMIC_NUMBER")
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
else  # argument doesn't exist
  echo "Please provide an element as an argument."; exit 0;
fi # argument exists fi