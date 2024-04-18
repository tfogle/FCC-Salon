#!/bin/bash




PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"




SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")




echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?\n"






MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi




    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done




  read SERVICE_ID_SELECTED




  #check if service exists
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      #book the service
      BOOK $SERVICE_ID_SELECTED
  fi
}




BOOK() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE




  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")




        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE';")
        # get SERVICE_TIME
        SERVICE_ID=$1
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id ='$1';")
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
        read SERVICE_TIME
        # insert appointment
        INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID', '$SERVICE_TIME');")
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."


}


MAIN_MENU
