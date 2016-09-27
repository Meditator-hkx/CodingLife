# SQL Learning

## Week 1 - Basis

### Show all the info of the table
	 SELECT * FROM TABLE_NAME;
	 
--
### Create a new table
	 CREATE TABLE TABLE_NAME (
	     column_1 datatype,
	     column_2 datatype,
	     column_3 datatype
	 );

--
### Insert a new record
	INSERT INTO TABLE_NAME  (colum_1,colum_2,colum_3)
	VALUES (col_1_data, col_2_data, col_3_data);
	
	SELECT column_x FROM TABLE_NAME
	
--
### Update specified record
	UPDATE TABLE_NAME 
	SET column_x = data_x
	WHERE column_y = data_y
	
--
### Ad a new column 
	ALTER TABLE TABLE_NAME
	ADD COLUMN
	COLUMN_NAME datatype;
	
--

### Delete all of the rows that have a `NULL` value in specified column

	DELETE FROM TABLE_NAME
	WHERE column_x 
	IS NULL;
	
--

## Week 2 - Compuatation

### Select from a column with filtering

	SELECT DISTINCT column_x 
	FROM TABLE_NAME;
	
--
### Conditional SELECT

	SELECT * FROM TABLE_NAME
	WHERE column_x ...; (meets with a condition)

- `=` means ==equals==
- `!=` means ==not equals==
- `>` means ==greater than==
- `<` means ==less than==
- `>=` means ==greater than or equal to==
- `<=`means ==less than or equal to==

--
### LIKE function

	SELECT * FROM TABLE_NAME
	WHERE column_x LIKE _STRING;
	
	SELECT * FROM TABLE_NAME
	WHERE column_x LIKE 's%';
	
`%` is a wildcard that matches zero or more missing letters in  the pattern.

--

### BETWEEN function

	SELECT * FROM TABLE_NAME
	WHERE column_x BETWEEN data_1 AND data_2;
	
--

### AND vs OR

	SELECT * FROM TABLE_NAME
	WHERE con_1 AND con_2;

	SELECT * FROM TABLE_NAME
	WHERE con_1 OR con_2;
	
--
	
### Sort in order

	SELECT * FROM TABLE_NAME
	ORDER BY column_x DESC;
	
	SELECT * FROM TABLE_NAME
	ORDER BY column_x ASC
	LIMIT number_x;

`LIMIT` gives the limitation of number shown at board.
  

## Week 3 - Arregation

### Count the number

	SELECT COUNT(*) FROM TABLE_NAME;
	
`COUNT()` is a function that takes the name of a column as an argument and counts the number of rows where the column is not `NULL`. Here, we want to count every row so we pass `*` as an argument.

--

### Count and group

	SELECT column_x, COUNT(*) FROM TABLE_NAME
	GROUP BY column_x;
	
Aggregate functions are more useful when they organize data into groups.

`GROUP BY` is a clause in SQL that is only used with aggregate functions. It is used in collaboration with the `SELECT` statement to arrange identical data into groups.

Here, our aggregate function is `COUNT()` and we are passing price as an argument to `GROUP BY`. SQL will count the total number of apps for each price in the table.

It is usually helpful to `SELECT` the column you pass as an argument to `GROUP BY`. Here we select price and `COUNT(*)`. You can see that the result set is organized into two columns making it easy to see the number of apps at each price.

--

### SUM with condition

	SELECT SUM(column_x) FROM TABLE_NAME;
	
--
	
### MAX function

	SELECT MAX(column_x) FROM TABLE_NAME;

You can find the largest value in a column by using `MAX()`.

`MAX()` is a function that takes the name of a column as an argument and returns the largest value in that column. Here, we pass downloads as an argument so it will return the largest value in the downloads column.

--

### MIN function
	SELECT MIN(column_x) FROM TABLE_NAME;
	
Similar to `MAX()`, SQL also makes it easy to return the smallest value in a column by using the `MIN()` function.

`MIN()` is a function that takes the name of a column as an argument and returns the smallest value in that column. Here, we pass downloads as an argument so it will return the smallest value in the downloads column.

--

### AVG function

	SELECT AVG(column_x) FROM TABLE_NAME;
	
This statement returns the average number of downloads for an app in our database. SQL uses the `AVG()` function to quickly calculate the average value of a particular column.

The `AVG()` function works by taking a column name as an argument and returns the average value for that column.

--

### ROUND function

	SELECT column_x, ROUND(AVG(column_y), number) 
	FROM TABLE_NAME
	GROUP BY column_x;
	
By default, SQL tries to be as precise as possible without rounding. We can make the result set easier to read using the `ROUND()` function.

`ROUND()` is a function that takes a column name and an integer as an argument. It rounds the values in the column to the number of decimal places specified by the integer. Here, we pass the column `AVG(downloads)` and `2` as arguments. SQL first calculates the average for each price and then rounds the result to two decimal places in the result set.


## Week 4 - Multiple tables

### PRIMARY KEY
	CREATE TABLE TABLE_NAME(
	id INTEGER PRIMARY KEY, 
	name TEXT);
	
Using the `CREATE TABLE` statement we added a PRIMARY KEY to the id column.

A primary key serves as a unique identifier for each row or record in a given table. The primary key is literally an id value for a record. We're going to use this value to connect artists to the albums they have produced.

By specifying that the id column is the `PRIMARY KEY`, SQL makes sure that:

- None of the values in this column are `NULL`
- Each value in this column is unique
- A table can not have more than one `PRIMARY KEY` column

--

### Key mapping among tables

	SELECT * FROM albums WHERE artist_id = 3;
	SELECT * FROM artists WHERE id = 3;
	
A foreign key is a column that contains the primary key of another table in the database. We use foreign keys and primary keys to connect rows in two different tables. One table's foreign key holds the value of another table's primary key. Unlike primary keys, foreign keys do not need to be unique and can be `NULL`.

Here, `artist_id` is a ==foreign key== in the albums table. We can see that Michael Jackson has an id of 3 in the artists table. All of the albums by Michael Jackson also have a 3 in the artist_id column in the albums table.

This is how SQL is linking data between the two tables. The relationship between the artists table and the albums table is the id value of the artists.

### Cross Join - 1

	SELECT albums.name, albums.year, artists.name 
	FROM albums, artists	
	
One way to query multiple tables is to write a `SELECT` statement with multiple table names separated by a comma. This is also known as a ==cross join==. Here, albums and artists are the different tables we are querying.

When querying more than one table, column names need to be specified by `table_name.column_name`. Here, the result set includes the name and year columns from the albums table and the name column from the artists table.

Unfortunately the result of this cross join is not very useful. It combines every row of the artists table with every row of the albums table. It would be more useful to only combine the rows where the album was created by the artist.

--

### Cross Join - 2

	SELECT * FROM
    albums JOIN artists ON
	albums.artist_id = artists.id;
	
In SQL, joins are used to combine rows from two or more tables. The most common type of join in SQL is an inner join.

An inner join will combine rows from different tables if the join condition is true. Let's look at the syntax to see how it works.

1. `SELECT *` specifies the columns our result set will have. Here, we want to include every column in both tables.
2. `FROM albums` specifies the first table we are querying.
3. `JOIN artists ON` specifies the type of join we are going to use as well as the name of the second table. Here, we want to do an inner join and the second table we want to query is `artists`.
4. `albums.artist_id = artists.id`is the join condition that describes how the two tables are related to each other. Here, SQL uses the foreign key column `artist_id` in the  albums table to match it with exactly one row in the artists table with the same value in the `id` column. We know it will only match one row in the artists table because `id` is the `PRIMARY KEY` of `artists`.

--

### LEFT JOIN

	SELECT
 	 *
	FROM
	  albums
	LEFT JOIN artists ON
	  albums.artist_id = artists.id;
	  
Outer joins also combine rows from two or more tables, but unlike inner joins, they do not require the join condition to be met. Instead, every row in the left table is returned in the result set, and if the join condition is not met, then `NULL` values are used to fill in the columns from the right table.

The left table is simply the first table that appears in the statement. Here, the left table is `albums`. Likewise, the right table is the second table that appears. Here, `artists` is the right table.

--

### AS function

	SELECT
	  albums.name AS 'Album',
	  albums.year,
	  artists.name AS 'Artist'
	FROM
	  albums
	JOIN artists ON
	  albums.artist_id = artists.id
	WHERE
	  albums.year > 1980;
	  
`AS` is a keyword in SQL that allows you to rename a column or table using an alias. The new name can be anything you want as long as you put it inside of single quotes. Here we want to rename the `albums.name` column as `'Album'`, and the `artists.name` column as `'Artist'`.

It is important to note that the columns have not been renamed in either table. The aliases only appear in the result set.

**Four-week course is over ...**
