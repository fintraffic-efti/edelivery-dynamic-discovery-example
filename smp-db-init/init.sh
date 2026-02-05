#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error when substituting.
set -o pipefail

SQL_ROOT=/opt/sql

# recreate database
echo "clean the database $DATABASE if exists "
mysql -h $DB_HOST -u $DB_ADMIN --password=$DB_ADMIN_PASSWORD -e "drop schema if exists $DATABASE; DROP USER IF EXISTS $DB_USERNAME; create schema $DATABASE; alter database $DATABASE charset=utf8; create user $DB_USERNAME identified by '$DB_PASSWORD'; grant all on $DATABASE.* to $DB_USERNAME;"

# create new database
echo "create database"
mysql -h $DB_HOST -u $DB_ADMIN --password=$DB_ADMIN_PASSWORD $DATABASE < "$SQL_ROOT/mysql5innodb.ddl"
echo "init users"
mysql -h $DB_HOST -u $DB_ADMIN --password=$DB_ADMIN_PASSWORD $DATABASE < "$SQL_ROOT/smp-db-init.sql"
