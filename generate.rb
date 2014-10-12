#!/usr/bin/env ruby

BASE_PATH = File.join('.', File.dirname(__FILE__))
require File.join(BASE_PATH, 'lib', 'startups_by_city')

options     = StartupsByCity::Options.parse
data_file   = StartupsByCity::DataFile.get_path(options[:data_file_method])
collection  = StartupsByCity::Collection.build(data_file)
StartupsByCity::Renderer.render(collection, options[:google_analytics])

puts
puts 'Done!'
