#! /bin/bash

PSQL="psql --username=postgres --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

SERVICES_AVAILABLE=$($PSQL "select service_id, name from services;")

echo -e "\nWelcome to My Salon, how can I help you?\n"

#SERVICE MENU
SERVICE_MENU(){
  if [[ $1 ]]
    then 
    echo -e "\n$1\n"
  fi

  if [[ -z $SERVICES_AVAILABLE ]]
  then
    SERVICE_MENU "No services Available."
    else
      echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR NAME
      do
       echo "$SERVICE_ID) $NAME" 
      done

      read SERVICE_ID_SELECTED 

      if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-5]+$ ]]
      then
      SERVICE_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # get costumer
        CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")
        
        # if not costumer
        if [[ -z $CUSTOMER_NAME ]]
        then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
          # insert customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
        fi

        SERVICE_NAME=$($PSQL "select name from services WHERE service_id = '$SERVICE_ID_SELECTED';")
        CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")

        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        APPOINTMENT_ID=$($PSQL "select appointment_id from appointments where customer_id = '$CUSTOMER_ID' AND service_id = '$SERVICE_ID_SELECTED' AND time = '$SERVICE_TIME' ;")

        if [[ -z $APPOINTMENT_ID ]]
        then
          INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

        fi

      fi
  fi
}

SERVICE_MENU