pinterest_crawler
=================

crawling pinterest
Use one of the following options to run this, passing -a to any of them would append the result to the previews time

Crawl the first page, this will only get the first 50 pins on the homepage
ruby get_boards.rb

Crawl all the pins and boards of owner of the first 50 pins on the homepage, -d is for deep crawl
ruby get_board.rb -d

Given a pinterest_username for example mdoroudi it crawls all the boards and pins of the user
ruby get_boards.rb [pinterest_username]

This will create two output files pins.json and boards.json
