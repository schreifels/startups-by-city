require 'haml'
require 'i18n'
I18n.available_locales = [:en]

module StartupsByCity
  module Renderer
    class << self
      def render(collection)
        puts
        puts 'Preparing output directory...'
        `mkdir -p #{File.join(BASE_PATH, 'output')}`
        `rm -f #{File.join(BASE_PATH, 'output', '*')}`
        `cp #{File.join(BASE_PATH, 'assets', '*')} #{File.join(BASE_PATH, 'output')}`

        layout_engine = Haml::Engine.new(File.read(File.join(BASE_PATH, 'templates', 'layout.html.haml'))).
            render_proc(Object.new, :collection, :country_name, :region_name, :city_name, :city_startups)

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
        int.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/) { "#{$1}," }
      end

      def city_path(country_name, state_name, city_name)
        # transliterate ensures we only use ASCII characters in the URL
        "#{I18n.transliterate(city_name)} #{I18n.transliterate(state_name)} #{I18n.transliterate(country_name)}".
            downcase.gsub(/\W+/, '-') + '.html'
      end
    end
  end
end
