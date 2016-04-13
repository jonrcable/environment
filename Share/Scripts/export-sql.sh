#!/bin/bash
#
# Create individual SQL files for each database. These files
# are imported automatically during an initial provision if
# the databases exist per the import-sql.sh process.

printf "\nWe are going to start importing databases\n"

if [ -z "$1" ]
then
_thisPath="../Databases/default"
else
_thisPath="../Databases/$1"
fi
printf " * from $_thisPath\n"

if [ ! -d "$_thisPath" ];
then
  mkdir -p "$_thisPath"
  printf " * creating path\n"
else
  printf " * already exists\n"
fi

printf " * start MySQL database export\n"
cd "$_thisPath"

mysql -uhomestead -psecret -e 'show databases' | \
grep -v -F "information_schema" | \
grep -v -F "performance_schema" | \
grep -v -F "mysql" | \
grep -v -F "test" | \
grep -v -F "Database" | \
grep -v -F "sys" | \
while read dbname; do mysqldump -uhomestead -psecret $dbname > $dbname.sql && echo "Database $dbname backed up..."; done