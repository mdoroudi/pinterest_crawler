Pinterest Crawler
=================
### How to run

Add `-a` to any of the following command and it will append the results to the already existing `pins.json` or `boards.json`. If you don't add `-a` this would overwrite the previewsly created pins.json and bords.json

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
$ rake crawl:users:from_seed
```
