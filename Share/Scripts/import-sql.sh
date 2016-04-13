#!/bin/bash
#
# Import provided SQL files in to MySQL.
#
# The files in the {vvv-dir}/database/backups/ directory should be created by
# mysqldump or some other export process that generates a full set of SQL commands
# to create the necessary tables and data required by a database.
#
# For an import to work properly, the SQL file should be named `db_name.sql` in which
# `db_name` matches the name of a database already created in {vvv-dir}/database/init-custom.sql
# or {vvv-dir}/database/init.sql.
#
# If a filename does not match an existing database, it will not import correctly.
#
# If tables already exist for a database, the import will not be attempted again. After an
# initial import, the data will remain persistent and available to MySQL on future boots
# through {vvv-dir}/database/data
#
# Let's begin...

# Move into the newly mapped backups directory, where mysqldump(ed) SQL files are stored

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

printf " * start MySQL database import\n"
cd "$_thisPath"

# Parse through each file in the directory and use the file name to
# import the SQL file into the database of the same name
sql_count=`ls -1 *.sql 2>/dev/null | wc -l`
if [ $sql_count != 0 ]
then
	for file in $( ls *.sql )
	do
	    pre_dot=${file%%.sql}
        mysql_cmd='SHOW TABLES FROM `'$pre_dot'`' # Required to support hypens in database names
        db_exist=`mysql -uhomestead -psecret --skip-column-names -e "$mysql_cmd"`
        if [ "$?" != "0" ]
        then
            printf " * creating $pre_dot database\n"
            mysql_create='CREATE DATABASE `'$pre_dot'`' # Required to support hypens in database names
            mysql -uhomestead -psecret --skip-column-names -e "$mysql_create"
        fi
        printf " * importing archive\n"
        mysql -uhomestead -psecret $pre_dot < $pre_dot.sql
	done
	printf " * databases imported\n"
else
	printf " * no custom databases to import\n"
fi