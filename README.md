# utf8mb4-convert

Converts a MariaDB or MySQL database, its tables and its character fields to charset utf8mb4 and collation
utf8mb4_unicode_ci (usually from charset utf8 and collation utf8_general_ci).

**Use at your own risk.**

**Test the conversion on a non-production database.**


**Make sure you back up any production database before running this script.**

## Usage

Save the script to your current path and give it execution rights:

```bash
curl -O https://raw.githubusercontent.com/fleio/utf8mb4-convert/main/convert.sh
chmod +x convert.sh
```

Running `./convert.sh` script without arguments shows help text:

```
  convert.sh <database_name> [connection parameters ...]

All given parameters are directly given to the mysql command and our convert query is piped to this command.

Include the database name at the minimum, also any connection params, like user and password.
Example usage: convert.sh my_database --user=my_user --password=the_password
See mysql documentation for more parameters.
```

**Script expects the database name to be the first parameter.**

Example:

```bash
./convert.sh databasename -h 127.0.0.1
```

The script shows the generated convert query first. This way you can just copy/paste the query and run it manually
yourself (instead of letting the script to run the query). Also asks for confirmation twice before actually messing with
your data.

## License

BSD 3-Clause License

## Thanks

Based on this StackExchange answer: https://dba.stackexchange.com/a/104866/222730

