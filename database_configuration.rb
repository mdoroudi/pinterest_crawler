require 'rubygems'
require 'active_record'
require 'mysql2'

dbconfig = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)


