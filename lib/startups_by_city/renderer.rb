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

        puts
        puts 'Rendering sidebar partial...'
        sidebar_html = Haml::Engine.new(template_content('_sidebar')).
            render(Object.new, collection: collection)

        puts
        puts 'Rendering layout...'
        layout_engine = Haml::Engine.new(template_content('layout')).
            render_proc(Object.new, :sidebar_html, :content_html, :full_location_name)
        File.write(
          File.join(BASE_PATH, 'output', 'index.html'),
          layout_engine.call(sidebar_html: sidebar_html)
        )

        puts
        puts 'Rendering city pages...'
        city_engine = Haml::Engine.new(template_content('city')).render_proc(Object.new, :location_name, :startups)
        collection.each do |country|
          country[:regions].each do |region|
            region[:cities].each do |city|
              location_name = "#{city[:name]}, #{StartupsByCity::Regions.translate_region_code(country[:name], region[:name])}"
              full_location_name = "#{city[:name]}, #{region[:name]}, #{country[:name]}"
              puts "  Rendering page for #{full_location_name}"
              File.write(
                File.join(BASE_PATH, 'output', city_path(country[:name], region[:name], city[:name])),
                layout_engine.call(
                  sidebar_html: sidebar_html,
                  content_html: city_engine.call(location_name: location_name, startups: city[:startups]),
                  full_location_name: full_location_name
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

      def city_path(country, state, city)
        # transliterate ensures we only use ASCII characters in the URL
        "#{I18n.transliterate(city)} #{I18n.transliterate(state)} #{I18n.transliterate(country)}".
            downcase.gsub(/\W+/, '-') + '.html'
      end

      private

      def template_content(template_name)
        File.read(File.join(BASE_PATH, 'templates', template_name + '.html.haml'))
      end
    end
  end
end
