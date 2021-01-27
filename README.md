# utf8mb4-convert

Converts a MariaDB or MySQL database, its tables and its character fields to charset utf8mb4 and collection
utf8mb4_unicode_ci (usually from charset utf8 and collation utf8_general_ci).

**Use at your own risk.**

**Test the conversion on a non-production database.**


**Make sure you back up any production database before running this script.**

## Usage

```
  convert.sh <database_name> [connection parameters ...]

All given parameters are directly given to the mysql command.
Include the database name at the minimum, also any connection params, like user and password.
Example usage: convert.sh my_database --user=my_user --password=the_password
See mysql documentation for more parameters.
```

Example:

```bash
./convert.sh databasename -h 127.0.0.1
```

## License

BSD License

## Thanks

Based on this StackExchange answer: https://dba.stackexchange.com/a/104866/222730

