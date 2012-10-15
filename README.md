Pinterest Crawler
=================
### Create database tables if you want to analyse the data through mysql
```sh
$ ruby database_configuration.rb
```

### How to run
These rake tasks always append the result to the end of the files if they already exist or create new ones if not.
if you don't want to append just empty the result files (boards.json, pins.json or users.json) 

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

Given a user slug get all it's fololowers and followings, and for each get their follower and followings, the limit right no is 500 users
```sh
$ rake crawl:users:from_seed seed=mdoroudi
```
