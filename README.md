Pinterest Crawler
=================
### How to run

Add `-a` to any of the following command and it will append the results to the already existing `pins.json` or `boards.json`. If you don't add `-a` this would overwrite the previewsly created pins.json and bords.json

Get all the boards and pins from user mdoroudi. Replace the username mdoroudi whith whatever username you want.
this creates two result files: `pins.json` and `boards.json`
```sh
$ ruby crawler.rb mdoroudi  
```

Get first 50 pins of the main page
this creates one result file: `pins.json`
```sh
$ ruby crawler.rb
```

From the first page get the user of all the first 50 pins and crawl their boards and pins
this crates two result files: `pins.json` and `boards.json`

```sh
$ ruby crawler.rb -d
```
