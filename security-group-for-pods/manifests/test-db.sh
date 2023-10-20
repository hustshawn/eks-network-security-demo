#!/bin/sh

export PGPASSWORD=$DB_PWD
export PGCONNECT_TIMEOUT=5

psql -U $DB_USER -h $DB_HOST -c "select count(*) from information_schema.tables" -d postgres
psql_exit_status=$?

echo "#######################################"
echo "#####  DATABASE CONNECTION RESULT #####"
echo "#######################################"

if [ $psql_exit_status != 0 ]; then
   echo "Database connection failed :(" 1>&2
   exit $psql_exit_status
fi

echo "Database connection successful :)"
exit 0