require_relative 'pin_and_board_crawler'
require_relative 'user_crawler'
require 'bundler'
require 'colorize'


task :default => ["print_instruction"] do
end

task :print_instruction do
  puts "To run this task do one of the following, by default the result gets append to the previews:".blue
  puts "\t rake crawl:pins_boards:pins_from_homepage ".green
  puts "\t rake crawl:pins_boards:from_seed seed=mdoroudi".green
  puts "\t rake crawl:pins_boards:from_homepage_deep".green
  puts "\t rake crawl:users:from_seed".green
end

namespace :crawl do

  namespace :pins_boards do
    desc "crawling pins from homepage"
    task :pins_from_homepage do
      crawler = PinAndBoardCrawler.new()
      crawler.crawl_from_main_page
    end

    desc "crawling users pins and boards from home page - deep"
    task :from_homepage_deep do
      crawler = PinAndBoardCrawler.new()
      crawler.crawl_from_main_page(true)
    end

    desc "crawling pins and boards from a seed"
    task :from_seed do
      params = {seed: ENV['seed']}
      crawler = PinAndBoardCrawler.new(params)
      crawler.crawl_from_seed
    end
  end

  namespace :users do
    desc "crawling users only from a seed"
    task :from_seed do
      params = { seed: ENV['seed'] }
      crawler = UserCrawler.new(params)
      crawler.crawl_users_from_seed(ENV['seed'])
    end

    desc "crawling users from homepage"
    task :from_homepage do
    end
  end

end

