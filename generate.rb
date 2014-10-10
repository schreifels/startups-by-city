#!/usr/bin/env ruby

BASE_PATH = File.join('.', File.dirname(__FILE__))
require File.join(BASE_PATH, 'lib', 'startups_by_city')

data_file   = StartupsByCity::DataFile.get_path
collection  = StartupsByCity::Collection.build(data_file)
StartupsByCity::Renderer.render(collection)
