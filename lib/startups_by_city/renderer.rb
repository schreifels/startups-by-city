require 'haml'

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
            render_proc(Object.new, :sidebar_html, :content_html, :location_name)
        File.write(File.join(BASE_PATH, 'output', 'index.html'), layout_engine.call(sidebar_html: sidebar_html))

        puts
        puts 'Rendering city pages...'
        city_engine = Haml::Engine.new(template_content('city')).render_proc(Object.new, :startups)
        collection.each do |country, regions|
          regions.each do |region, cities|
            cities.each do |city|
              location_name = "#{city[:name]}, #{region}, #{country}"
              puts "  Rendering page for #{location_name}"
              File.write(
                File.join(BASE_PATH, 'output', city_path(country, region, city)),
                layout_engine.call(sidebar_html: sidebar_html, content_html: city_engine.call(startups: city[:startups]), location_name: location_name)
              )
            end
          end
        end
      end

      def city_path(country, state, city)
        "#{city[:name]} #{state} #{country}".downcase.gsub(/\W+/, '-') + '.html'
      end

      private

      def template_content(template_name)
        File.read(File.join(BASE_PATH, 'templates', template_name + '.html.haml'))
      end
    end
  end
end
