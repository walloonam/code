#!/bin/bash


DB_USER=$(whoami)
DB_PASSWORD=$(whoami)
DB_NAME="instance"

QUERY="SELECT * FROM status WHERE username='$DB_USER';"

result=$(mysql -u user2 -puser2 $DB_NAME -se "$QUERY")

echo "$result"