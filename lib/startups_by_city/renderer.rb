require 'haml'
require 'i18n'
I18n.available_locales = [:en]
I18n.config.enforce_available_locales = true

module StartupsByCity
  module Renderer
    class << self
      def render(collection, google_analytics)
        puts
        puts 'Preparing output directory...'
        `mkdir -p #{File.join(BASE_PATH, 'output')}`
        `rm -f #{File.join(BASE_PATH, 'output', '*')}`
        `cp #{File.join(BASE_PATH, 'assets', '*')} #{File.join(BASE_PATH, 'output')}`

        layout_engine = Haml::Engine.new(File.read(File.join(BASE_PATH, 'templates', 'layout.html.haml'))).
            render_proc(Object.new, :google_analytics, :collection, :country_name, :region_name, :city_name, :city_startups)

        puts
        if google_analytics
          puts "Using Google Analytics tracking code #{google_analytics}..."
        else
          puts 'No Google Analytics tracking code specified, skipping...'
        end

        puts
        puts 'Rendering index...'
        File.write(
          File.join(BASE_PATH, 'output', 'index.html'),
          layout_engine.call(collection: collection)
        )

        puts
        puts 'Rendering city pages...'
        collection.each do |country|
          country[:regions].each do |region|
            region[:cities].each do |city|
              puts "  Rendering page for #{city[:name]}, #{region[:name]}, #{country[:name]}"
              File.write(
                File.join(BASE_PATH, 'output', city_path(country[:name], region[:name], city[:name])),
                layout_engine.call(
                  google_analytics: google_analytics,
                  collection: collection,
                  country_name: country[:name],
                  region_name: region[:name],
                  city_name: city[:name],
                  city_startups: city[:startups]
                )
              )
            end
          end
        end
      end

      def delimit_number(int)
        # Borrowed from ActiveSupport::NumberHelper
        @delimited_numbers ||= {}
        @delimited_numbers[int.to_s] ||= int.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/) { "#{$1}," }
      end

      def city_path(country_name, state_name, city_name)
        @city_paths ||= {}
        # transliterate ensures we only use ASCII characters in the URL
        @city_paths[country_name + state_name + city_name] ||=
            "#{I18n.transliterate(city_name)} #{I18n.transliterate(state_name)} #{I18n.transliterate(country_name)}".
            downcase.gsub(/\W+/, '-') + '.html'
      end
    end
  end
end
