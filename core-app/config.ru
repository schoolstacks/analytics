# Rackup file to load WebApp.rb server
# To run from dev CLI:
#   rackup -p 8080 config.ru
require 'rubygems'
require 'bundler'
require './lib/lt_base.rb'

LT::boot_all
path = File::expand_path(File::dirname(__FILE__))
require File::join(path, 'lib', 'webapp.rb')
puts "Run enviroment mode: #{LT::run_env}"
run LT::WebApp