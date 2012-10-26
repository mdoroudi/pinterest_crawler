Pinterest Crawler
=================

### How to run
These rake tasks create new files or override exisiting json files, so make sure if you have old data back them up.
the results are some of these: boards.json, pins.json or users.json

### Boards & Pins

Get all the boards and pins from user mdoroudi. Replace the username mdoroudi whith whatever username you want.
this creates two result files: `pins.json` and `boards.json`
```sh
$ rake crawl:pins_boards:from_seed seed=mdoroudi
```

Get first 50 pins of the main page
this creates one result file: `pins.json`
```sh
$ rake crawl:pins_boards:pins_from_homepage 
```

From the first page get the user of all the first 50 pins and crawl their boards and pins
this crates two result files: `pins.json` and `boards.json`

```sh
$ rake crawl:pins_boards:from_homepage_deep
```

### Users
Given a user slug get all it's fololowers and followings, and for each get their follower and followings, the limit right no is 500 users

```sh
$ rake crawl:users:from_seed seed=mdoroudi
```

## Load data into your mysql database
To analyze the data further you might want to load the data into mysql database, (right now it only pins and boards).

### Create Tables
before creating tables, make sure you have a `config/database.yml` file that almost looks like this but has your info in it

#### Database

```yml
adapter: mysql2
encoding: utf8
host: localhost
database: pinterest
user: root
password: 
```

and also create your database, in my case it's called `pinterest`

```sql
> create database pinterest
```

#### Tables
This process creates the following three table: 
* users
* pins
* boards

```sh
$ rake create_tables:all
```

#### Load data
loads the json data into the corresponding tables

```sh
$ rake load_data:all 
```

