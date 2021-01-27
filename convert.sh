#!/bin/bash

set -e

show_help() {
  local help_text="
Converts databases from utf8 to utf8mb4, including all tables and fields.

  convert.sh <database_name> [connection parameters ...]
All given parameters are directly given to the mysql command.
Include the database name at the minimum, also any connection params, like user and password.
Example usage: convert.sh my_database --user=my_user --password=the_password
See mysql documentation for more parameters.
"
  echo "$help_text"
}

database="$1"

confirm_continuation() {
  read -r confirmed
  if [ "$confirmed" != "y" ] && [ "$confirmed" != "Y" ]; then
    echo "Exiting ..."
    exit
  fi
}

if [ -z "$database" ]; then
  echo "Database name argument is required" >&2
  show_help
  exit 1
else
  query_generator=$'
USE information_schema;
SELECT CONCAT("ALTER DATABASE `",table_schema,"` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;") AS _sql
FROM `TABLES` WHERE table_schema LIKE "'"$database"$'" AND TABLE_TYPE=\'BASE TABLE\' GROUP BY table_schema UNION
SELECT CONCAT("ALTER TABLE `",table_schema,"`.`",table_name,"` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;") AS _sql
FROM `TABLES` WHERE table_schema LIKE "'"$database"$'" AND TABLE_TYPE=\'BASE TABLE\' GROUP BY table_schema, table_name UNION
SELECT CONCAT("ALTER TABLE `",`COLUMNS`.table_schema,"`.`",`COLUMNS`.table_name, "` CHANGE `",column_name,"` `",column_name,"` ",data_type,"(",character_maximum_length,") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",IF(is_nullable="YES"," NULL"," NOT NULL"),";") AS _sql
FROM `COLUMNS` INNER JOIN `TABLES` ON `TABLES`.table_name = `COLUMNS`.table_name WHERE `COLUMNS`.table_schema like "'"$database"$'" and data_type in (\'varchar\',\'char\') AND TABLE_TYPE=\'BASE TABLE\' UNION
SELECT CONCAT("ALTER TABLE `",`COLUMNS`.table_schema,"`.`",`COLUMNS`.table_name, "` CHANGE `",column_name,"` `",column_name,"` ",data_type," CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci",IF(is_nullable="YES"," NULL"," NOT NULL"),";") AS _sql
FROM `COLUMNS` INNER JOIN `TABLES` ON `TABLES`.table_name = `COLUMNS`.table_name WHERE `COLUMNS`.table_schema like "'"$database"$'" and data_type in (\'text\',\'tinytext\',\'mediumtext\',\'longtext\') AND TABLE_TYPE=\'BASE TABLE\';
'

  echo ""
  echo "This script will convert the database, tables and string fields to utf8mb4 utf8mb4_unicode_ci."
  echo ""
  echo "To see the charset of each field in your database before running this script and after running the script,"
  echo "run this query in the mysql console (replace database_name):"
  echo '  SELECT DISTINCT column_name,table_name,character_set_name,collation_name FROM information_schema.columns WHERE table_schema = "database_name" AND character_set_name IS NOT NULL;'
  echo ""
  echo "It is highly recommended to first run this script on a copy of the production database."
  echo "If you run this on a live production database, make sure you backup your database first !!!"
  echo ""
  echo "Next we'll output a list of queries that will run against the database."
  echo "After showing the queries you'll be asked for confirmation before actually running them."
  echo "You'll also be able to CTRL+C to exit de script, copy the queries and run them manually by yourself."
  echo ""
  echo -n "  Continue showing the queries? [y/N] "
  confirm_continuation
  generated_queries="$(echo "$query_generator" | mysql $* | tail -n +2)"
  generated_queries="SET foreign_key_checks = 0;
$generated_queries
SET foreign_key_checks = 1;"
  echo "$generated_queries"

  echo ""
  echo "The queries above will be run against database $database"
  echo -n "  Continue running the queries? (you did backed up, right?) [y/N] "
  confirm_continuation
  echo ""
  echo "  This may take a while, depending on your database size ..."
  echo ""

  echo "$generated_queries" | mysql $*
fi
