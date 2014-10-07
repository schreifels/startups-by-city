#!/usr/bin/env ruby

require 'csv'
require 'haml'

## Generate hash of startups ###################################################

puts 'Generating hash...'

def to_path(country, state, city)
  "#{city} #{state} #{country}".downcase.gsub(/\W+/, '-') + '.html'
end

source_file = Dir['source/crunchbase_*.csv'].last
raise 'Cannot find source file' unless File.exists?(source_file)

i = 1
skips = 0
startups = {} # { country: { state: { city: [startup1, startup2, ...] } } }
CSV.foreach(source_file, headers: true) do |source_row|
  puts "  Indexed #{i} startups" if i % 10000 == 0
  i += 1

  if source_row['location_country_code'].nil? || source_row['location_region'].nil? || source_row['location_city'].nil?
    skips += 1
    next
  end

  startups[source_row['location_country_code']] ||= {}
  startups[source_row['location_country_code']][source_row['location_region']] ||= {}
  startups[source_row['location_country_code']][source_row['location_region']][source_row['location_city']] ||= []
  startups[source_row['location_country_code']][source_row['location_region']][source_row['location_city']] <<
    source_row.to_hash.select { |k, v| ['name', 'short_description', 'homepage_url', 'crunchbase_url'].include?(k) }
end

puts "Skipped #{skips} records"

## Cleansing data ##############################################################

puts 'Cleansing data...'

startups.each do |country, states|
  states.each do |state, cities|
    cities.each do |city, startups_in_city|
      if startups_in_city.length < 10
        startups[country][state].delete(city)
      end
    end
  end
end

## Render homepage #############################################################

puts 'Generating sidebar partial...'

sidebar_html = Haml::Engine.new(File.read('templates/_sidebar.html.haml')).render(Object.new, startups: startups)

puts 'Rendering layout...'

layout_engine = Haml::Engine.new(File.read('templates/layout.html.haml')).render_proc(Object.new, :sidebar_html, :content_html)
File.write('output/index.html', layout_engine.call(sidebar_html: sidebar_html))

## Render city pages ###########################################################

puts 'Rendering city pages...'

engine = Haml::Engine.new(File.read('templates/city.html.haml')).render_proc(Object.new, :startups)
startups.each do |country, regions|
  regions.each do |region, cities|
    cities.each do |city, startups_in_city|
      puts "  Rendering page for #{city}, #{region}, #{country}"
      File.write('output/' + to_path(country, region, city), layout_engine.call(sidebar_html: sidebar_html, content_html: engine.call(startups: startups_in_city)))
    end
  end
end
