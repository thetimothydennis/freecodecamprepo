#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\nWelcome to the salon!\n\nHere are the services we are offering today.\n"

# Service menu function
SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # Display services offered
  echo "$($PSQL 'SELECT * FROM services')" | sed -E 's/\|/) /'
  SERVICE_IDS="$($PSQL 'SELECT service_id FROM services')"
  echo -e "\nWhich service are you interested in?\n"
  read SERVICE_ID_SELECTED
  # Verify the service exists
  if [[ ! $SERVICE_IDS =~ $SERVICE_ID_SELECTED ]]
  # If not, offer the menu again
  then
    SERVICE_MENU "I'm sorry, it appears that service doesn't exist."
  else
    # If the service exists, ask for the customer phone number
    echo -e "What is your phone number?"
    read CUSTOMER_PHONE
    # get customer phone numbers from customers table
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get customer name
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      # Store phone and number in customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # Get service time
    echo -e "\nWhat time would you like to have your appointment?"
    read SERVICE_TIME
    # Store appointment in appointment table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

SERVICE_MENU

